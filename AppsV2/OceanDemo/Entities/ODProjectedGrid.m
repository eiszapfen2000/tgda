#import <Foundation/NSArray.h>
#import <Foundation/NSData.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import "Log/NPLog.h"
#import "Core/Container/NPAssetArray.h"
#import "Core/Utilities/NSData+NPEngine.h"
#import "Core/World/NPTransformationState.h"
#import "Core/NPEngineCore.h"
#import "Graphics/Buffer/NPBufferObject.h"
#import "Graphics/Buffer/NPCPUBuffer.h"
#import "Graphics/Geometry/NPCPUVertexArray.h"
#import "Graphics/Geometry/NPVertexArray.h"
#import "Graphics/Effect/NPEffect.h"
#import "Graphics/Effect/NPEffectTechnique.h"
#import "Graphics/Effect/NPEffectVariableFloat.h"
#import "Graphics/Texture/NPTexture2D.h"
#import "Graphics/Texture/NPTextureBindingState.h"
#import "Graphics/NPEngineGraphics.h"
#import "ODProjector.h"
#import "ODProjectedGrid.h"

static FVector3 computeBasePlanePosition(const Matrix4 * const inverseViewProjection,
                                         Plane basePlane,
                                         Vector2 postProjectionVertex)
{
    const Vector4 nearPlaneVertex
        = {postProjectionVertex.x, postProjectionVertex.y, -1.0, 1.0};

    const Vector4 farPlaneVertex
        = {postProjectionVertex.x, postProjectionVertex.y, 1.0, 1.0};

    const Vector4 resultN = m4_mv_multiply(inverseViewProjection, &nearPlaneVertex);
    const Vector4 resultF = m4_mv_multiply(inverseViewProjection, &farPlaneVertex);

    Ray ray;
    ray.point.x = resultN.x / resultN.w;
    ray.point.y = resultN.y / resultN.w;
    ray.point.z = resultN.z / resultN.w;

    ray.direction.x = (resultF.x / resultF.w) - ray.point.x;
    ray.direction.y = (resultF.y / resultF.w) - ray.point.y;
    ray.direction.z = (resultF.z / resultF.w) - ray.point.z;

    Vector3 intersection;
    int32_t r = plane_pr_intersect_with_ray_v(&basePlane, &ray, &intersection);

    FVector3 result;
    result.x = intersection.x;
    result.y = intersection.y;
    result.z = intersection.z;

    return result;
}

static FVector3 computeBasePlanePositionF(const FMatrix4 * const inverseViewProjection,
                                          FPlane basePlane,
                                          FVector2 postProjectionVertex)
{
    const FVector4 nearPlaneVertex
        = {postProjectionVertex.x, postProjectionVertex.y, -1.0, 1.0};

    const FVector4 farPlaneVertex
        = {postProjectionVertex.x, postProjectionVertex.y, 1.0, 1.0};

    const FVector4 resultN = fm4_mv_multiply(inverseViewProjection, &nearPlaneVertex);
    const FVector4 resultF = fm4_mv_multiply(inverseViewProjection, &farPlaneVertex);

    FRay ray;
    ray.point.x = resultN.x / resultN.w;
    ray.point.y = resultN.y / resultN.w;
    ray.point.z = resultN.z / resultN.w;

    ray.direction.x = (resultF.x / resultF.w) - ray.point.x;
    ray.direction.y = (resultF.y / resultF.w) - ray.point.y;
    ray.direction.z = (resultF.z / resultF.w) - ray.point.z;

    FVector3 intersection;
    int32_t r = fplane_pr_intersect_with_ray_v(&basePlane, &ray, &intersection);

    FVector3 result;
    result.x = intersection.x;
    result.y = intersection.y;
    result.z = intersection.z;

    return result;
}

@interface ODProjectedGrid (Private)

- (void) computeBasePlaneCornerVertices;
- (void) updateResolution;

@end

@implementation ODProjectedGrid (Private)

- (void) computeBasePlaneCornerVertices
{
    const Vector2 upperLeft  = {-1.0,  1.0};
    const Vector2 upperRight = { 1.0,  1.0};
    const Vector2 lowerLeft  = {-1.0, -1.0};
    const Vector2 lowerRight = { 1.0, -1.0};

    const Matrix4 * const invViewProjection = [ projector inverseViewProjection ];

    cornerVertices[0] = computeBasePlanePosition(invViewProjection, basePlane, lowerLeft);
    cornerVertices[1] = computeBasePlanePosition(invViewProjection, basePlane, lowerRight);
    cornerVertices[2] = computeBasePlanePosition(invViewProjection, basePlane, upperRight);
    cornerVertices[3] = computeBasePlanePosition(invViewProjection, basePlane, upperLeft);

    FPlane plane;
    FMatrix4 invVP;
    fm4_m_init_with_m4(&invVP, invViewProjection);

    fplane_pssss_init_with_components(&plane, 0.0f, 1.0f, 0.0f, 0.0f);

    const FVector2 upperLeftf  = {-1.0f,  1.0f};
    const FVector2 upperRightf = { 1.0f,  1.0f};
    const FVector2 lowerLeftf  = {-1.0f, -1.0f};
    const FVector2 lowerRightf = { 1.0f, -1.0f};

    FVector3 cornersF[4];

    cornersF[0] = computeBasePlanePositionF(&invVP, plane, lowerLeftf);
    cornersF[1] = computeBasePlanePositionF(&invVP, plane, lowerRightf);
    cornersF[2] = computeBasePlanePositionF(&invVP, plane, upperRightf);
    cornersF[3] = computeBasePlanePositionF(&invVP, plane, upperLeftf);

    
    /*
    for (int32_t i = 0; i < 4; i++)
    {
        //NSLog(@"\n%s\n%s", fv3_v_to_string(&(cornerVertices[i])), fv3_v_to_string(&(cornersF[i])));
        NSLog(@"%d %s", i, fv3_v_to_string(&(cornerVertices[i])));
    }
    */
    
    cornerVertices[0] = (FVector3){-1.0, 0.0, -1.0};
    cornerVertices[1] = (FVector3){ 1.0, 0.0, -1.0};
    cornerVertices[2] = (FVector3){ 1.0, 0.0,  1.0};
    cornerVertices[3] = (FVector3){-1.0, 0.0,  1.0};    
}

- (void) updateResolution
{
    SAFE_FREE(nearPlanePostProjectionPositions);
    SAFE_FREE(gridIndices);

    const size_t numberOfVertices = resolution.x * resolution.y;
    const size_t numberOfIndices
        = (resolution.x - 1) * (resolution.y - 1) * 6;

    nearPlanePostProjectionPositions = ALLOC_ARRAY(FVertex2, numberOfVertices);
    gridIndices = ALLOC_ARRAY(uint16_t, numberOfIndices);

    const double deltaX = 2.0 / ((double)(resolution.x - 1));
    const double deltaY = 2.0 / ((double)(resolution.y - 1));

    // scanlinewise starting from lowerleft
    // due to render to vertexbuffer memory layout
    // needs to be same memory layout as textures
    for ( int32_t i = 0; i < resolution.y; i++ )
    {
        for ( int32_t j = 0; j < resolution.x; j++ )
        {
            const int32_t index = (i * resolution.x) + j;
            nearPlanePostProjectionPositions[index].x = (float)(-1.0 + j * deltaX);
            nearPlanePostProjectionPositions[index].y = (float)(-1.0 + i * deltaY);
        }
    }

    vertexStep.x = deltaX;
    vertexStep.y = deltaY;

    // IMPORTANT
    // vertex coordinates after render to vertexbuffer
    // fragment at pixel center, shifted in respect to vertices!?!?

    // Index layout
    // 3 --- 2
    // |     |
    // 0 --- 1

    for ( int32_t i = 0; i < resolution.y - 1; i++ )
    {
        for ( int32_t j = 0; j < resolution.x - 1; j++ )
        {
            const uint16_t subIndex0 = i * resolution.x + j;
            const uint16_t subIndex1 = i * resolution.x + j + 1;
            const uint16_t subIndex2 = (i + 1) * resolution.x + j + 1;
            const uint16_t subIndex3 = (i + 1) * resolution.x + j;

            const int32_t quadrangleIndex = (i * (resolution.x - 1) + j) * 6;

            gridIndices[quadrangleIndex]   = subIndex0;
            gridIndices[quadrangleIndex+1] = subIndex1;
            gridIndices[quadrangleIndex+2] = subIndex2;

            gridIndices[quadrangleIndex+3] = subIndex2;
            gridIndices[quadrangleIndex+4] = subIndex3;
            gridIndices[quadrangleIndex+5] = subIndex0;
        }
    }

    NSData * vertexData
        = [ NSData dataWithBytesNoCopyNoFree:nearPlanePostProjectionPositions
                                      length:sizeof(FVertex2) * numberOfVertices ];

    NSData * indexData
        = [ NSData dataWithBytesNoCopyNoFree:gridIndices
                                      length:sizeof(uint16_t) * numberOfIndices ];

    BOOL result
        = [ gridVertexStream generate:NpCPUBufferTypeGeometry
                           dataFormat:NpBufferDataFormatFloat32
                           components:2
                                 data:vertexData
                                error:NULL ];

    result
        = result && [ gridIndexStream generate:NpCPUBufferTypeIndices
                                    dataFormat:NpBufferDataFormatUInt16
                                    components:1
                                          data:indexData
                                         error:NULL ];

    result
        = result && [ gridVertexArray setVertexStream:gridVertexStream 
                                           atLocation:NpVertexStreamPositions
                                                error:NULL ];

    result
        = result && [ gridVertexArray setIndexStream:gridIndexStream 
                                               error:NULL ];

    NSAssert(result, @"");

    result
        = result && [ transformedVertexStream generate:NpBufferObjectTypeGeometry
                                            updateRate:NpBufferDataUpdateOftenUseOften
                                             dataUsage:NpBufferDataCopyGPUToGPU
                                            dataFormat:NpBufferDataFormatFloat32
                                            components:3
                                                  data:[ NSData data ]
                                            dataLength:numberOfIndices * sizeof(FVector3)
                                                 error:NULL ];

    result
        = result && [ transformedNonDisplacedVertexStream
                         generate:NpBufferObjectTypeGeometry
                       updateRate:NpBufferDataUpdateOftenUseOften
                        dataUsage:NpBufferDataCopyGPUToGPU
                       dataFormat:NpBufferDataFormatFloat32
                       components:2
                             data:[ NSData data ]
                       dataLength:numberOfIndices * sizeof(FVector2)
                            error:NULL ];

    result
        = result && [ transformTarget setVertexStream:transformedVertexStream 
                                           atLocation:NpVertexStreamPositions
                                                error:NULL ];

    result
        = result && [ transformTarget setVertexStream:transformedNonDisplacedVertexStream 
                                           atLocation:NpVertexStreamAttribute1
                                                error:NULL ];

    NSAssert(result, @"");
}

@end

@implementation ODProjectedGrid

- (id) init
{
    return [ self initWithName:@"ODProjectedGrid" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    resolutionLastFrame.x = resolutionLastFrame.y = 0;
    resolution.x = resolution.y = 0;

    vertexStep = v2_zero();

    // y = 0 plane
    plane_pssss_init_with_components(&basePlane, 0.0, 1.0, 0.0, 0.0);

    // resolution independent
    cornerVertices = ALLOC_ARRAY(FVertex3, 4);
    cornerIndices  = ALLOC_ARRAY(uint16_t, 6);
    cornerIndices[0] = 0;
    cornerIndices[1] = 1;
    cornerIndices[2] = 2;
    cornerIndices[3] = 2;
    cornerIndices[4] = 3;
    cornerIndices[5] = 0;

    cornerVertexArray = [[ NPCPUVertexArray alloc ] init ];
    gridVertexArray   = [[ NPCPUVertexArray alloc ] init ];

    transformTarget = [[ NPVertexArray alloc ] init ];

    gridVertexStream   = [[ NPCPUBuffer alloc ] initWithName:@"gridVertexStream" ];
    gridIndexStream    = [[ NPCPUBuffer alloc ] initWithName:@"gridIndexStream" ];
    cornerVertexStream = [[ NPCPUBuffer alloc ] initWithName:@"cornerVertexStream" ];
    cornerIndexStream  = [[ NPCPUBuffer alloc ] initWithName:@"cornerIndexStream" ];

    transformedVertexStream = [[ NPBufferObject alloc ] initWithName:@"transformedVertexStream" ];
    transformedNonDisplacedVertexStream
        = [[ NPBufferObject alloc ] initWithName:@"transformedNonDisplacedVertexStream" ];

    NSData * cornerVertexData
        = [ NSData dataWithBytesNoCopyNoFree:cornerVertices
                                      length:sizeof(FVertex3) * 4 ];

    NSData * cornerIndexData
        = [ NSData dataWithBytesNoCopyNoFree:cornerIndices
                                      length:sizeof(uint16_t) * 6 ];

    BOOL result
        = [ cornerVertexStream generate:NpCPUBufferTypeGeometry
                             dataFormat:NpBufferDataFormatFloat32
                             components:3
                                   data:cornerVertexData
                                  error:NULL ];

    result
        = result && [ cornerIndexStream generate:NpCPUBufferTypeIndices
                                      dataFormat:NpBufferDataFormatUInt16
                                      components:1
                                            data:cornerIndexData
                                           error:NULL ];

    result
        = result && [ cornerVertexArray setVertexStream:cornerVertexStream 
                                             atLocation:NpVertexStreamPositions
                                                  error:NULL ];

    result
        = result && [ cornerVertexArray setIndexStream:cornerIndexStream 
                                                 error:NULL ];

    NSAssert(result, @"");

    glGenQueries(1, &query);

    return self;
}

- (void) dealloc
{
    glDeleteQueries(1, &query);

    SAFE_DESTROY(gridVertexArray);
    DESTROY(gridVertexStream);
    DESTROY(gridIndexStream);
    DESTROY(cornerVertexArray);
    DESTROY(cornerIndexStream);
    DESTROY(cornerVertexStream);
    DESTROY(transformTarget);
    DESTROY(transformedVertexStream);
    DESTROY(transformedNonDisplacedVertexStream);

    SAFE_DESTROY(projector);

    SAFE_FREE(nearPlanePostProjectionPositions);
    FREE(cornerVertices);
    SAFE_FREE(gridIndices);
    FREE(cornerIndices);

    [ super dealloc ];
}

- (IVector2) resolution
{
    return resolution;
}

- (Vector2) vertexStep
{
    return vertexStep;
}

- (void) setResolution:(const IVector2)newResolution
{
    resolution = newResolution;
}

- (void) setProjector:(ODProjector *)newProjector
{
    ASSIGN(projector, newProjector);
}

- (void) update:(const double)frameTime
{
    NSAssert(projector != nil, @"No projector attached");

    if ( resolutionLastFrame.x != resolution.x
        || resolutionLastFrame.y != resolution.y )
    {
        [ self updateResolution ];

        resolutionLastFrame = resolution;
    }

    [ self computeBasePlaneCornerVertices ];
}

- (void) renderTFTransform
{
    glEnable(GL_RASTERIZER_DISCARD);
        glBindBufferBase(GL_TRANSFORM_FEEDBACK_BUFFER, 0, [ transformedVertexStream glID ]);
        glBindBufferBase(GL_TRANSFORM_FEEDBACK_BUFFER, 1, [ transformedNonDisplacedVertexStream glID ]);
        glBeginQuery(GL_TRANSFORM_FEEDBACK_PRIMITIVES_WRITTEN, query);
        glBeginTransformFeedback(GL_TRIANGLES);
            [ gridVertexArray renderWithPrimitiveType:NpPrimitiveTriangles ];
        glEndTransformFeedback();
        glEndQuery(GL_TRANSFORM_FEEDBACK_PRIMITIVES_WRITTEN);
        glBindBufferBase(GL_TRANSFORM_FEEDBACK_BUFFER, 0, 0);
        glBindBufferBase(GL_TRANSFORM_FEEDBACK_BUFFER, 1, 0);
    glDisable(GL_RASTERIZER_DISCARD);
}

- (void) renderTFFeedback
{
    GLuint primitivesWritten = 0;
    glGetQueryObjectuiv(query, GL_QUERY_RESULT, &primitivesWritten);

    [ transformTarget
        renderWithPrimitiveType:NpPrimitiveTriangles
                     firstIndex:0
                      lastIndex:(primitivesWritten * 3) - 1];
}

- (void) render
{
    [ gridVertexArray renderWithPrimitiveType:NpPrimitiveTriangles ];
}

@end

