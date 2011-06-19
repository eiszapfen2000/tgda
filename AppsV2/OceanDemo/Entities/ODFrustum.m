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
#import "Graphics/NPEngineGraphics.h"
#import "ODFrustum.h"

int compare_floats (const void * a, const void * b)
{
    float temp = *((float *)a) - *((float *)b);

    if (temp > 0.0f)
    {
        return -1;
    }
    else if (temp < 0.0f)
    {
        return 1;
    }
    else
    {
        return 0;
    }
}


@implementation ODFrustum

- (id) init
{
    return [ self initWithName:@"ODFrustum" ];
}

- (id) initWithName:(NSString *)newName
{
    self =  [ super initWithName:newName ];

    frustumLineIndices[0] = frustumLineIndices[7] = frustumLineIndices[16] = 0;
    frustumLineIndices[1] = frustumLineIndices[2] = frustumLineIndices[18] = 1;
    frustumLineIndices[3] = frustumLineIndices[4] = frustumLineIndices[20] = 2;
    frustumLineIndices[5] = frustumLineIndices[6] = frustumLineIndices[22] = 3;
    frustumLineIndices[8] = frustumLineIndices[15] = frustumLineIndices[17] = 4;
    frustumLineIndices[9] = frustumLineIndices[10] = frustumLineIndices[19] = 5;
    frustumLineIndices[11] = frustumLineIndices[12] = frustumLineIndices[21] = 6;
    frustumLineIndices[13] = frustumLineIndices[14] = frustumLineIndices[23] = 7;

    // Quad on near plane
    defaultFaceIndices[0] = 0;
    defaultFaceIndices[1] = 1;
    defaultFaceIndices[2] = 2;
    defaultFaceIndices[3] = 3;

    // Quad on far plane
    defaultFaceIndices[4] = 4;
    defaultFaceIndices[5] = 5;
    defaultFaceIndices[6] = 6;
    defaultFaceIndices[7] = 7;

    //Top Quad
    defaultFaceIndices[8] = 3;
    defaultFaceIndices[9] = 2;
    defaultFaceIndices[10] = 6;
    defaultFaceIndices[11] = 7;

    //Bottom Quad
    defaultFaceIndices[12] = 0;
    defaultFaceIndices[13] = 1;
    defaultFaceIndices[14] = 5;
    defaultFaceIndices[15] = 4;

    // Left quad
    defaultFaceIndices[16]  = 3;
    defaultFaceIndices[17]  = 0;
    defaultFaceIndices[18] = 4;
    defaultFaceIndices[19] = 7;

    //Right Quad
    defaultFaceIndices[20] = 1;
    defaultFaceIndices[21] = 2;
    defaultFaceIndices[22] = 6;
    defaultFaceIndices[23] = 5;

    memcpy(frustumFaceIndices, defaultFaceIndices, sizeof(defaultFaceIndices));

    vertexData
        = [[ NSData alloc ]
                initWithBytesNoCopy:frustumCornerPositions
                             length:sizeof(frustumCornerPositions)
                       freeWhenDone:NO ];

    indexData
        = [[ NSData alloc ]
                initWithBytesNoCopy:defaultFaceIndices
                             length:sizeof(defaultFaceIndices)
                       freeWhenDone:NO ];

    vertexStream = [[ NPCPUBuffer alloc ] init ];
    indexStream  = [[ NPCPUBuffer alloc ] init ];

    BOOL result
        = [ vertexStream generate:NpBufferObjectTypeGeometry
                       dataFormat:NpBufferDataFormatFloat32
                       components:3
                             data:vertexData
                       dataLength:[ vertexData length ]
                            error:NULL ];

    NSAssert(result, @"");

    result = [ indexStream generate:NpBufferObjectTypeIndices
                         dataFormat:NpBufferDataFormatUInt16
                         components:1
                               data:indexData
                         dataLength:[ indexData length ]
                              error:NULL ];

    NSAssert(result, @"");

    vertexArray = [[ NPCPUVertexArray alloc ] init ];
    result = [ vertexArray addVertexStream:vertexStream
                                atLocation:NpVertexStreamAttribute0
                                     error:NULL ];

    NSAssert(result, @"");

    result = [ vertexArray addIndexStream:indexStream error:NULL ];

    NSAssert(result, @"");

    effect
        = [[[ NPEngineGraphics instance ] effects ]
                getAssetWithFileName:@"default.effect" ];

    ASSERT_RETAIN(effect);

    return self;
}

- (void) dealloc
{
    DESTROY(effect);
    DESTROY(vertexArray);
    DESTROY(indexStream);
    DESTROY(vertexStream);
    DESTROY(indexData);
    DESTROY(vertexData);

    [ super dealloc ];
}

- (void) updateWithPosition:(const FVector3)position
                orientation:(const FQuaternion)orientation
                        fov:(const float)fov
                  nearPlane:(const float)nearPlane
                   farPlane:(const float)farPlane
                aspectRatio:(const float)aspectRatio
{
    // compute near and far plane size

    const float fovradians = DEGREE_TO_RADIANS(fov/2.0f);

    const float nearPlaneHeight = 2.0f * tanf(fovradians) * nearPlane;
    const float farPlaneHeight  = 2.0f * tanf(fovradians) * farPlane;
    const float nearPlaneWidth  = nearPlaneHeight * aspectRatio;
    const float farPlaneWidth   = farPlaneHeight * aspectRatio;

    const float nearPlaneHalfHeight = nearPlaneHeight / 2.0f;
    const float nearPlaneHalfWidth  = nearPlaneWidth  / 2.0f;
    const float farPlaneHalfHeight  = farPlaneHeight  / 2.0f;
    const float farPlaneHalfWidth   = farPlaneWidth   / 2.0f;

    // compute forward, up and right vector

    FVector3 forward = fquat_q_forward_vector(&orientation);
    FVector3 up = fquat_q_up_vector(&orientation);
    FVector3 right = fquat_q_right_vector(&orientation);

    fv3_v_normalise(&forward);
    fv3_v_normalise(&up);
    fv3_v_normalise(&right);

    // compute frustum bounds with the near plane center at the origin
    // so we can apply an uniform scale to the vertices to shrink
    // the frustum to an acceptable size for rendering

    const FVector3 farPlaneHalfWidthV  = fv3_sv_scaled(farPlaneHalfWidth, &right);
    const FVector3 farPlaneHalfHeightV = fv3_sv_scaled(farPlaneHalfHeight, &up);
    const FVector3 nearPlaneHalfWidthV  = fv3_sv_scaled(nearPlaneHalfWidth, &right);
    const FVector3 nearPlaneHalfHeightV = fv3_sv_scaled(nearPlaneHalfHeight, &up);

    // near plane stuff
    const FVector3 nearPlaneCenter = (FVector3){0.0f, 0.0f, 0.0f};

    const FVector3 npDirection = fv3_vv_add(&nearPlaneHalfHeightV, &nearPlaneHalfWidthV);
    const FVector3 nearPlaneUpperCenter = fv3_vv_add(&nearPlaneCenter, &nearPlaneHalfHeightV);
    const FVector3 nearPlaneLowerCenter = fv3_vv_sub(&nearPlaneCenter, &nearPlaneHalfHeightV);

    frustumCornerPositions[NEARPLANE_UPPERRIGHT] = fv3_vv_add(&nearPlaneCenter, &npDirection);
    frustumCornerPositions[NEARPLANE_LOWERLEFT]  = fv3_vv_sub(&nearPlaneCenter, &npDirection);
    frustumCornerPositions[NEARPLANE_UPPERLEFT]  = fv3_vv_sub(&nearPlaneUpperCenter, &nearPlaneHalfWidthV);
    frustumCornerPositions[NEARPLANE_LOWERRIGHT] = fv3_vv_add(&nearPlaneLowerCenter, &nearPlaneHalfWidthV);

    // far plane stuff
    const FVector3 farPlaneCenter = fv3_sv_scaled(farPlane - nearPlane, &forward);

    const FVector3 fpdirection = fv3_vv_add(&farPlaneHalfHeightV, &farPlaneHalfWidthV);
    const FVector3 farPlaneUpperCenter = fv3_vv_add(&farPlaneCenter, &farPlaneHalfHeightV);
    const FVector3 farPlaneLowerCenter = fv3_vv_sub(&farPlaneCenter, &farPlaneHalfHeightV);

    frustumCornerPositions[FARPLANE_UPPERRIGHT] = fv3_vv_add(&farPlaneCenter, &fpdirection);
    frustumCornerPositions[FARPLANE_LOWERLEFT]  = fv3_vv_sub(&farPlaneCenter, &fpdirection);
    frustumCornerPositions[FARPLANE_UPPERLEFT]  = fv3_vv_sub(&farPlaneUpperCenter, &farPlaneHalfWidthV);
    frustumCornerPositions[FARPLANE_LOWERRIGHT] = fv3_vv_add(&farPlaneLowerCenter, &farPlaneHalfWidthV);

    // scale frustum geometry
    const FMatrix3 scale = fm3_s_scale(0.05f);

    for ( int32_t i = 0; i < 8; i++ )
    {
        frustumCornerPositions[i] = fm3_mv_multiply(&scale, &(frustumCornerPositions[i]));
    }

    // translate frustum to world space
    const FVector3 fromPositionToNearPlane = fv3_sv_scaled(nearPlane, &forward);
    const FVector3 nearPlaneWorldSpacePosition  = fv3_vv_add(&position, &fromPositionToNearPlane);

    for ( int32_t i = 0; i < 8; i++ )
    {
        frustumCornerPositions[i] = fv3_vv_add(&(frustumCornerPositions[i]), &nearPlaneWorldSpacePosition);
    }
}

- (void) render
{
    [[[ NPEngineCore instance ] transformationState ] resetModelMatrix ];

    [[ effect techniqueWithName:@"render" ] activate ];

    [ vertexArray renderWithPrimitiveType:NpPrimitiveQuads ];

    /*
    ODCamera * camera = [[[[ NP applicationController ] sceneManager ] currentScene ] camera ];
    FVector3 * position = [ camera position ];

    float squareDistances[6];
    float sortedSquareDistances[6];

    for ( Int i = 0; i < 6; i++ )
    {
        FVertex3 midPoint = fvertex_aass_calculate_indexed_MassCenter3D(frustumCornerPositions, &(defaultFaceIndices[i*4]), 8, 4);
        squareDistances[i] = fv3_vv_square_distance(&midPoint, position);
        sortedSquareDistances[i] = squareDistances[i];
    }

    qsort(sortedSquareDistances, 6, sizeof(float), compare_floats);

    for ( Int i = 0; i < 6; i++ )
    {
        Int32 index = -1;

        for ( Int j = 0; j < 6; j++ )
        {
            if ( (sortedSquareDistances[i] == squareDistances[j]) && (index == -1))
            {
                index = j;
                squareDistances[j] = 0.0f;
            }
        }

        frustumFaceIndices[i*4]   = defaultFaceIndices[index*4];
        frustumFaceIndices[i*4+1] = defaultFaceIndices[index*4+1];
        frustumFaceIndices[i*4+2] = defaultFaceIndices[index*4+2];
        frustumFaceIndices[i*4+3] = defaultFaceIndices[index*4+3];
    }

    [[[ NP Core ] transformationState ] resetModelMatrix ];

    [[[[ NP Graphics ] stateConfiguration ] blendingState ] setEnabled:YES ];
    [[[[ NP Graphics ] stateConfiguration ] blendingState ] setBlendingMode:NP_BLENDING_AVERAGE ];
    [[[[ NP Graphics ] stateConfiguration ] blendingState ] activate ];

    [[[[ NP Graphics ] stateConfiguration ] cullingState ] setEnabled:NO ];
    [[[[ NP Graphics ] stateConfiguration ] cullingState ] activate ];

    [[[[ NP Graphics ] stateConfiguration ] depthTestState ] setEnabled:YES ];
    [[[[ NP Graphics ] stateConfiguration ] depthTestState ] setWriteEnabled:NO ];
    [[[[ NP Graphics ] stateConfiguration ] depthTestState ] activate ];

    glLineWidth(5.0f);

    FVector4 color = { 0.0f, 1.0f, 0.0f, 0.5f };
    [ frustumEffect uploadFVector4ParameterWithName:@"color" andValue:&color ];

    [ frustumEffect activateTechniqueWithName:@"render" ];
    [ frustumFaceGeometry renderWithPrimitiveType:NP_GRAPHICS_VBO_PRIMITIVES_QUADS ];

    [[[[ NP Graphics ] stateConfiguration ] blendingState ] setEnabled:NO ];
    [[[[ NP Graphics ] stateConfiguration ] blendingState ] activate ];

    [ frustumEffect activateTechniqueWithName:@"render" ];
    [ frustumLineGeometry renderWithPrimitiveType:NP_GRAPHICS_VBO_PRIMITIVES_LINES ];

    [ frustumEffect deactivate ];

    glLineWidth(1.0f);
    */
}

@end
