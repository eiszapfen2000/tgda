#define _GNU_SOURCE
#import <stdlib.h>
#import <Foundation/NSData.h>
#import <Foundation/NSException.h>
#import "Core/Container/NPAssetArray.h"
#import "Core/World/NPTransformationState.h"
#import "Core/NPEngineCore.h"
#import "Graphics/Buffer/NPCPUBuffer.h"
#import "Graphics/Geometry/NPCPUVertexArray.h"
#import "Graphics/Effect/NPEffect.h"
#import "Graphics/Effect/NPEffectTechnique.h"
#import "Graphics/Effect/NPEffectVariableFloat.h"
#import "Graphics/State/NPBlendingState.h"
#import "Graphics/State/NPCullingState.h"
#import "Graphics/State/NPDepthTestState.h"
#import "Graphics/State/NPStateConfiguration.h"
#import "Graphics/NPEngineGraphics.h"
#import "ODFrustum.h"

@implementation ODFrustum

- (id) init
{
    return [ self initWithName:@"ODFrustum" ];
}

- (id) initWithName:(NSString *)newName
{
    self =  [ super initWithName:newName ];

    memset(frustumCornerPositions,   0, sizeof(frustumCornerPositions));

    frustumLineIndices[0]  = frustumLineIndices[7]  = frustumLineIndices[16] = 0;
    frustumLineIndices[1]  = frustumLineIndices[2]  = frustumLineIndices[18] = 1;
    frustumLineIndices[3]  = frustumLineIndices[4]  = frustumLineIndices[20] = 2;
    frustumLineIndices[5]  = frustumLineIndices[6]  = frustumLineIndices[22] = 3;
    frustumLineIndices[8]  = frustumLineIndices[15] = frustumLineIndices[17] = 4;
    frustumLineIndices[9]  = frustumLineIndices[10] = frustumLineIndices[19] = 5;
    frustumLineIndices[11] = frustumLineIndices[12] = frustumLineIndices[21] = 6;
    frustumLineIndices[13] = frustumLineIndices[14] = frustumLineIndices[23] = 7;

    // Quad on near plane           // Quad on far plane
    frustumFaceIndices[0] = 0;      frustumFaceIndices[4] = 4;
    frustumFaceIndices[1] = 1;      frustumFaceIndices[5] = 5;
    frustumFaceIndices[2] = 2;      frustumFaceIndices[6] = 6;
    frustumFaceIndices[3] = 3;      frustumFaceIndices[7] = 7;

    //Top Quad                      //Bottom Quad
    frustumFaceIndices[8]  = 3;     frustumFaceIndices[12] = 0;
    frustumFaceIndices[9]  = 2;     frustumFaceIndices[13] = 1;
    frustumFaceIndices[10] = 6;     frustumFaceIndices[14] = 5;
    frustumFaceIndices[11] = 7;     frustumFaceIndices[15] = 4;

    // Left quad                    //Right Quad
    frustumFaceIndices[16] = 3;     frustumFaceIndices[20] = 1;
    frustumFaceIndices[17] = 0;     frustumFaceIndices[21] = 2;
    frustumFaceIndices[18] = 4;     frustumFaceIndices[22] = 6;
    frustumFaceIndices[19] = 7;     frustumFaceIndices[23] = 5;

    NSData * vertexData
        = [ NSData dataWithBytesNoCopy:frustumCornerPositions
                                length:sizeof(frustumCornerPositions)
                          freeWhenDone:NO ];

    NSData * facesIndexData
        = [ NSData dataWithBytesNoCopy:frustumFaceIndices
                                length:sizeof(frustumFaceIndices)
                          freeWhenDone:NO ];

    NSData * linesIndexData
        = [ NSData dataWithBytesNoCopy:frustumLineIndices
                                length:sizeof(frustumLineIndices)
                          freeWhenDone:NO ];


    vertexStream = [[ NPCPUBuffer alloc ] init ];
    facesIndexStream  = [[ NPCPUBuffer alloc ] init ];
    linesIndexStream  = [[ NPCPUBuffer alloc ] init ];

    BOOL result
        = [ vertexStream generate:NpCPUBufferTypeGeometry
                       dataFormat:NpBufferDataFormatFloat32
                       components:3
                             data:vertexData
                       dataLength:[ vertexData length ]
                            error:NULL ];

    NSAssert(result, @"");

    result
        = result && [ facesIndexStream generate:NpCPUBufferTypeIndices
                                     dataFormat:NpBufferDataFormatUInt16
                                     components:1
                                           data:facesIndexData
                                     dataLength:[ facesIndexData length ]
                                          error:NULL ];

    NSAssert(result, @"");

    result
        = result && [ linesIndexStream generate:NpCPUBufferTypeIndices
                                     dataFormat:NpBufferDataFormatUInt16
                                     components:1
                                           data:linesIndexData
                                     dataLength:[ linesIndexData length ]
                                          error:NULL ];

    NSAssert(result, @"");

    facesVertexArray = [[ NPCPUVertexArray alloc ] init ];
    linesVertexArray = [[ NPCPUVertexArray alloc ] init ];

    result
        = result && [ facesVertexArray setVertexStream:vertexStream
                                            atLocation:NpVertexStreamAttribute0
                                                 error:NULL ];

    result
        = result && [ linesVertexArray setVertexStream:vertexStream
                                            atLocation:NpVertexStreamAttribute0
                                                 error:NULL ];

    NSAssert(result, @"");

    result = result && [ facesVertexArray setIndexStream:facesIndexStream error:NULL ];
    result = result && [ linesVertexArray setIndexStream:linesIndexStream error:NULL ];

    NSAssert(result, @"");

    return self;
}

- (void) dealloc
{
    DESTROY(facesVertexArray);
    DESTROY(linesVertexArray);
    DESTROY(facesIndexStream);
    DESTROY(linesIndexStream);
    DESTROY(vertexStream);

    [ super dealloc ];
}

- (const FVector3 * const) frustumCornerPositions
{
    return frustumCornerPositions;
}

- (void) updateWithPosition:(const Vector3)position
                orientation:(const Quaternion)orientation
                        fov:(const double)fov
                  nearPlane:(const double)nearPlane
                   farPlane:(const double)farPlane
                aspectRatio:(const double)aspectRatio
{
    // compute near and far plane size

    const double fovradians = DEGREE_TO_RADIANS(fov / 2.0);

    const double nearPlaneHeight = 2.0 * tan(fovradians) * nearPlane;
    const double farPlaneHeight  = 2.0 * tan(fovradians) * farPlane;
    const double nearPlaneWidth  = nearPlaneHeight * aspectRatio;
    const double farPlaneWidth   = farPlaneHeight * aspectRatio;

    const double nearPlaneHalfHeight = nearPlaneHeight / 2.0;
    const double nearPlaneHalfWidth  = nearPlaneWidth  / 2.0;
    const double farPlaneHalfHeight  = farPlaneHeight  / 2.0;
    const double farPlaneHalfWidth   = farPlaneWidth   / 2.0;

    // compute forward, up and right vector

    Vector3 forward = quat_q_forward_vector(&orientation);
    Vector3 up = quat_q_up_vector(&orientation);
    Vector3 right = quat_q_right_vector(&orientation);

    v3_v_normalise(&forward);
    v3_v_normalise(&up);
    v3_v_normalise(&right);

    // compute frustum bounds with the near plane center at the origin
    // so we can apply an uniform scale to the vertices to shrink
    // the frustum to an acceptable size for rendering

    const Vector3 farPlaneHalfWidthV   = v3_sv_scaled(farPlaneHalfWidth, &right);
    const Vector3 farPlaneHalfHeightV  = v3_sv_scaled(farPlaneHalfHeight, &up);
    const Vector3 nearPlaneHalfWidthV  = v3_sv_scaled(nearPlaneHalfWidth, &right);
    const Vector3 nearPlaneHalfHeightV = v3_sv_scaled(nearPlaneHalfHeight, &up);

    // near plane stuff
    const Vector3 nearPlaneCenter = (Vector3){0.0, 0.0, 0.0};
    const Vector3 farPlaneCenter = v3_sv_scaled(farPlane - nearPlane, &forward);

    const Vector3 npDirection = v3_vv_add(&nearPlaneHalfHeightV, &nearPlaneHalfWidthV);
    const Vector3 fpdirection = v3_vv_add(&farPlaneHalfHeightV, &farPlaneHalfWidthV);

    const Vector3 nearPlaneUpperCenter = v3_vv_add(&nearPlaneCenter, &nearPlaneHalfHeightV);
    const Vector3 nearPlaneLowerCenter = v3_vv_sub(&nearPlaneCenter, &nearPlaneHalfHeightV);
    const Vector3 farPlaneUpperCenter = v3_vv_add(&farPlaneCenter, &farPlaneHalfHeightV);
    const Vector3 farPlaneLowerCenter = v3_vv_sub(&farPlaneCenter, &farPlaneHalfHeightV);

    Vector3 cornerPositions[8];
    cornerPositions[NEARPLANE_UPPERRIGHT] = v3_vv_add(&nearPlaneCenter, &npDirection);
    cornerPositions[NEARPLANE_LOWERLEFT]  = v3_vv_sub(&nearPlaneCenter, &npDirection);
    cornerPositions[NEARPLANE_UPPERLEFT]  = v3_vv_sub(&nearPlaneUpperCenter, &nearPlaneHalfWidthV);
    cornerPositions[NEARPLANE_LOWERRIGHT] = v3_vv_add(&nearPlaneLowerCenter, &nearPlaneHalfWidthV);
    cornerPositions[FARPLANE_UPPERRIGHT]  = v3_vv_add(&farPlaneCenter, &fpdirection);
    cornerPositions[FARPLANE_LOWERLEFT]   = v3_vv_sub(&farPlaneCenter, &fpdirection);
    cornerPositions[FARPLANE_UPPERLEFT]   = v3_vv_sub(&farPlaneUpperCenter, &farPlaneHalfWidthV);
    cornerPositions[FARPLANE_LOWERRIGHT]  = v3_vv_add(&farPlaneLowerCenter, &farPlaneHalfWidthV);

    for ( int32_t i = 0; i < 8; i++ )
    {
        frustumCornerPositions[i] = fv3_v_from_v3(&cornerPositions[i]);
    }

    // translate frustum to world space
    const Vector3 fromPositionToNearPlane = v3_sv_scaled(nearPlane, &forward);
    const Vector3 nearPlaneWorldSpacePosition = v3_vv_add(&position, &fromPositionToNearPlane);

    const FVector3 fromPositionToNearPlaneF = fv3_v_from_v3(&fromPositionToNearPlane);
    const FVector3 nearPlaneWorldSpacePositionF = fv3_v_from_v3(&nearPlaneWorldSpacePosition);

    for ( int32_t i = 0; i < 8; i++ )
    {
        frustumCornerPositions[i]   = fv3_vv_add(&(frustumCornerPositions[i]),   &nearPlaneWorldSpacePositionF);
    }
}

- (void) render
{
    [ facesVertexArray renderWithPrimitiveType:NpPrimitiveQuads ];
    [ linesVertexArray renderWithPrimitiveType:NpPrimitiveLines ];
}

@end
