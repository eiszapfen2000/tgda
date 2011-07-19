#import <Foundation/NSArray.h>
#import <Foundation/NSData.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import "Core/Container/NPAssetArray.h"
#import "Core/World/NPTransformationState.h"
#import "Core/NPEngineCore.h"
#import "Graphics/Buffer/NPCPUBuffer.h"
#import "Graphics/Geometry/NPCPUVertexArray.h"
#import "Graphics/Effect/NPEffect.h"
#import "Graphics/Effect/NPEffectTechnique.h"
#import "Graphics/Effect/NPEffectVariableFloat.h"
#import "Graphics/NPEngineGraphics.h"
#import "ODProjector.h"
#import "ODProjectedGrid.h"

@interface ODProjectedGrid (Private)

- (void) computeBasePlaneGeometryUsingRaycasting;
- (FVector4) computeBasePlanePosition:(const FVector2)postProjectionVertex;
- (void) computeBasePlaneCornerVertices;
- (void) computeBasePlaneGeometryUsingInterpolation;
- (void) updateResolution;

@end

@implementation ODProjectedGrid (Private)

- (void) computeBasePlaneGeometryUsingRaycasting
{
    const FMatrix4 * const inverseViewProjection = [ projector inverseViewProjection ];

    for ( int32_t i = 0; i < resolution.y; i++ )
    {
        for (int32_t j = 0; j < resolution.x; j++ )
        {
            const int32_t index = i * resolution.x + j;

            // near plane z = -1.0f
            FVector4 nearPlaneVertex = nearPlanePostProjectionPositions[index];
            // far plane z = 1.0f
            FVector4 farPlaneVertex  = nearPlaneVertex;
            farPlaneVertex.z = 1.0f;

            // transform to world space
            const FVector4 resultN = fm4_mv_multiply(inverseViewProjection, &nearPlaneVertex);
            const FVector4 resultF = fm4_mv_multiply(inverseViewProjection, &farPlaneVertex);

            // construct ray
            FRay ray;
            ray.point.x = resultN.x / resultN.w;
            ray.point.y = resultN.y / resultN.w;
            ray.point.z = resultN.z / resultN.w;

            ray.direction.x = (resultF.x / resultF.w) - ray.point.x;
            ray.direction.y = (resultF.y / resultF.w) - ray.point.y;
            ray.direction.z = (resultF.z / resultF.w) - ray.point.z;

            // interset ray with plane
            FVector3 intersection;
            int32_t r = fplane_pr_intersect_with_ray_v(&basePlane, &ray, &intersection);

            FVector4 result = fv4_v_from_fv3(&intersection);
            worldSpacePositions[index] = result;
        }
    }
}

- (FVector4) computeBasePlanePosition:(const FVector2)postProjectionVertex
{
    const FMatrix4 * const inverseViewProjection
        = [ projector inverseViewProjection ];

    const FVector4 nearPlaneVertex
        = {postProjectionVertex.x, postProjectionVertex.y, -1.0f, 1.0f};

    const FVector4 farPlaneVertex
        = {postProjectionVertex.x, postProjectionVertex.y, 1.0f, 1.0f};

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

    return fv4_v_from_fv3(&intersection);
}

- (void) computeBasePlaneCornerVertices
{
    const FVector2 upperLeft  = {-1.0f,  1.0f};
    const FVector2 upperRight = { 1.0f,  1.0f};
    const FVector2 lowerLeft  = {-1.0f, -1.0f};
    const FVector2 lowerRight = { 1.0f, -1.0f};

    cornerVertices[0] = [ self computeBasePlanePosition:lowerLeft  ];
    cornerVertices[1] = [ self computeBasePlanePosition:lowerRight ];
    cornerVertices[2] = [ self computeBasePlanePosition:upperRight ];
    cornerVertices[3] = [ self computeBasePlanePosition:upperLeft  ];
}

- (void) computeBasePlaneGeometryUsingInterpolation
{
    [ self computeBasePlaneCornerVertices ];

    float u = -1.0f;
    float v = -1.0f;

    float deltaX = 2.0f / (resolution.x - 1.0f);
    float deltaY = 2.0f / (resolution.y - 1.0f);

    for ( int32_t i = 0; i < resolution.y; i++ )
    {
        u = -1.0f;

        for ( int32_t j = 0; j < resolution.x; j++ )
        {
            const float w
                = (cornerVertices[0].w / 4.0f) * (1.0f - u)  * (1.0f - v) +
                  (cornerVertices[1].w / 4.0f) * (u + 1.0f ) * (1.0f - v) +
                  (cornerVertices[3].w / 4.0f) * (1.0f - u)  * (v + 1.0f) +
                  (cornerVertices[2].w / 4.0f) * (u + 1.0f ) * (v + 1.0f);

            const float x
                = (cornerVertices[0].x / 4.0f) * (1.0f - u)  * (1.0f - v) +
                  (cornerVertices[1].x / 4.0f) * (u + 1.0f ) * (1.0f - v) +
                  (cornerVertices[3].x / 4.0f) * (1.0f - u)  * (v + 1.0f) +
                  (cornerVertices[2].x / 4.0f) * (u + 1.0f ) * (v + 1.0f);

            const float z
                = (cornerVertices[0].z / 4.0f) * (1.0f - u)  * (1.0f - v) +
                  (cornerVertices[1].z / 4.0f) * (u + 1.0f ) * (1.0f - v) +
                  (cornerVertices[3].z / 4.0f) * (1.0f - u)  * (v + 1.0f) +
                  (cornerVertices[2].z / 4.0f) * (u + 1.0f ) * (v + 1.0f);

            const int32_t index = i * resolution.x + j;

            worldSpacePositions[index].x = x / w;
            worldSpacePositions[index].y = 0.0f;
            worldSpacePositions[index].z = z / w;
            worldSpacePositions[index].w = 1.0f;

            u = u + deltaX;
        }

        v = v + deltaY;
    }
}

- (void) updateResolution
{
    SAFE_FREE(nearPlanePostProjectionPositions);
    SAFE_FREE(worldSpacePositions);
    SAFE_FREE(gridIndices);

    const size_t numberOfVertices = resolution.x * resolution.y;
    const size_t numberOfIndices
        = (resolution.x - 1) * (resolution.y - 1) * 6;

    nearPlanePostProjectionPositions = ALLOC_ARRAY(FVertex4, numberOfVertices);
    worldSpacePositions = ALLOC_ARRAY(FVertex4, numberOfVertices);
    gridIndices = ALLOC_ARRAY(uint16_t, numberOfIndices);

    const float deltaX = 2.0f / ((float)(resolution.x - 1));
    const float deltaY = 2.0f / ((float)(resolution.y - 1));

    // scanlinewise starting from lowerleft
    // due to render to vertexbuffer memory layout
    // needs to be same memory layout as textures
    for ( int32_t i = 0; i < resolution.y; i++ )
    {
        for ( int32_t j = 0; j < resolution.x; j++ )
        {
            const int32_t index = (i * resolution.x) + j;
            nearPlanePostProjectionPositions[index].x = -1.0f + j * deltaX;
            nearPlanePostProjectionPositions[index].y = -1.0f + i * deltaY;
            nearPlanePostProjectionPositions[index].z = -1.0f; // near plane
            nearPlanePostProjectionPositions[index].w =  1.0f;
        }
    }

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

    /*
    NSData * vertexData
        = [ NSData dataWithBytesNoCopy:nearPlanePostProjectionPositions
                                length:sizeof(FVertex4) * numberOfVertices
                          freeWhenDone:NO ];
    */

    NSData * vertexData
        = [ NSData dataWithBytesNoCopy:worldSpacePositions
                                length:sizeof(FVertex4) * numberOfVertices
                          freeWhenDone:NO ];

    NSData * indexData
        = [ NSData dataWithBytesNoCopy:gridIndices
                                length:sizeof(uint16_t) * numberOfIndices
                          freeWhenDone:NO ];

    BOOL result
        = [ gridVertexStream generate:NpBufferObjectTypeGeometry
                       dataFormat:NpBufferDataFormatFloat32
                       components:4
                             data:vertexData
                       dataLength:[ vertexData length ]
                            error:NULL ];

    NSAssert(result, @"");

    result = [ gridIndexStream generate:NpBufferObjectTypeIndices
                         dataFormat:NpBufferDataFormatUInt16
                         components:1
                               data:indexData
                         dataLength:[ indexData length ]
                              error:NULL ];

    NSAssert(result, @"");

    SAFE_DESTROY(gridVertexArray);
    gridVertexArray = [[ NPCPUVertexArray alloc ] init ];

    result = [ gridVertexArray addVertexStream:gridVertexStream 
                                atLocation:NpVertexStreamPositions
                                     error:NULL ];

    NSAssert(result, @"");

    result = [ gridVertexArray addIndexStream:gridIndexStream 
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

    // y = 0 plane
    fplane_pssss_init_with_components(&basePlane, 0.0f, 1.0f, 0.0f, 0.0f);

    renderMode = ProjectedGridGPUInterpolation;

    // resolution independent
    cornerVertices = ALLOC_ARRAY(FVertex4, 4);
    cornerIndices  = ALLOC_ARRAY(uint16_t, 6);
    cornerIndices[0] = 0;
    cornerIndices[1] = 1;
    cornerIndices[2] = 2;
    cornerIndices[3] = 2;
    cornerIndices[4] = 3;
    cornerIndices[5] = 0;

    gridVertexStream   = [[ NPCPUBuffer alloc ] init ];
    gridIndexStream    = [[ NPCPUBuffer alloc ] init ];
    cornerVertexStream = [[ NPCPUBuffer alloc ] init ];
    cornerIndexStream  = [[ NPCPUBuffer alloc ] init ];

    NSData * cornerVertexData
        = [ NSData dataWithBytesNoCopy:cornerVertices
                                length:sizeof(FVertex4) * 4
                          freeWhenDone:NO ];

    NSData * cornerIndexData
        = [ NSData dataWithBytesNoCopy:cornerIndices
                                length:sizeof(uint16_t) * 6
                          freeWhenDone:NO ];

    BOOL result
        = [ cornerVertexStream generate:NpBufferObjectTypeGeometry
                             dataFormat:NpBufferDataFormatFloat32
                             components:4
                                   data:cornerVertexData
                             dataLength:[ cornerVertexData length ]
                                  error:NULL ];

    NSAssert(result, @"");

    result =
        [ cornerIndexStream generate:NpBufferObjectTypeIndices
                          dataFormat:NpBufferDataFormatUInt16
                          components:1
                                data:cornerIndexData
                          dataLength:[ cornerIndexData length ]
                               error:NULL ];

    NSAssert(result, @"");

    cornerVertexArray = [[ NPCPUVertexArray alloc ] init ];

    result = [ cornerVertexArray addVertexStream:cornerVertexStream 
                                      atLocation:NpVertexStreamPositions
                                           error:NULL ];

    NSAssert(result, @"");

    result = [ cornerVertexArray addIndexStream:cornerIndexStream 
                                    error:NULL ];

    NSAssert(result, @"");

    effect
        = [[[ NPEngineGraphics instance ] effects ]
                getAssetWithFileName:@"default.effect" ];

    ASSERT_RETAIN(effect);

    color = [ effect variableWithName:@"color" ];

    gridColor.x = 0.0f;
    gridColor.y = 0.0f;
    gridColor.z = 1.0f;
    gridColor.w = 1.0f;

    return self;
}

- (void) dealloc
{
    DESTROY(effect);
    SAFE_DESTROY(gridVertexArray);
    DESTROY(gridVertexStream);
    DESTROY(gridIndexStream);
    DESTROY(cornerVertexArray);
    DESTROY(cornerIndexStream);
    DESTROY(cornerVertexStream);

    SAFE_DESTROY(projector);

    SAFE_FREE(nearPlanePostProjectionPositions);
    SAFE_FREE(worldSpacePositions);
    FREE(cornerVertices);
    SAFE_FREE(gridIndices);
    FREE(cornerIndices);

    [ super dealloc ];
}

- (ODProjectedGridRenderMode) renderMode
{
    return renderMode;
}

- (IVector2) resolution
{
    return resolution;
}

- (void) setResolution:(const IVector2)newResolution
{
    resolution = newResolution;
}

- (void) setRenderMode:(const ODProjectedGridRenderMode)newRenderMode
{
    renderMode = newRenderMode;
}

- (void) setProjector:(ODProjector *)newProjector
{
    ASSIGN(projector, newProjector);
}

- (BOOL) loadFromDictionary:(NSDictionary *)config
                      error:(NSError **)error
{
    NSAssert(config != nil, @"");

    NSString * gridName          = [ config objectForKey:@"Name" ];
    NSArray  * resolutionStrings = [ config objectForKey:@"Resolution" ];

    if ( gridName == nil || resolutionStrings == nil )
    {
        if ( error != NULL )
        {
            *error = nil;
        }
        
        return NO;
    }

    [ self setName:gridName ];

    resolution.x = [[ resolutionStrings objectAtIndex:0 ] intValue ];
    resolution.y = [[ resolutionStrings objectAtIndex:1 ] intValue ];

    return YES;
}

- (void) update:(const float)frameTime
{
    NSAssert(projector != nil, @"No projector attached");

    if ( resolutionLastFrame.x != resolution.x
        || resolutionLastFrame.y != resolution.y )
    {
        [ self updateResolution ];

        resolutionLastFrame = resolution;
    }

    switch ( renderMode )
    {
        case ProjectedGridCPURaycasting:
        {
            [ self computeBasePlaneGeometryUsingRaycasting ];            
            break;
        }

        case ProjectedGridCPUInterpolation:
        {
            [ self computeBasePlaneGeometryUsingInterpolation ];
            break;
        }

        case ProjectedGridGPUInterpolation:
        {
            [ self computeBasePlaneCornerVertices ];
            break;
        }
    }
}

- (void) render
{
    [[[ NPEngineCore instance ] transformationState ] resetModelMatrix ];

    [ color setValue:gridColor ];
    [[ effect techniqueWithName:@"color" ] activate ];    

    switch ( renderMode )
    {
        case ProjectedGridCPURaycasting:
        case ProjectedGridCPUInterpolation:
        {
            [ gridVertexArray renderWithPrimitiveType:NpPrimitiveTriangles ];
            break;
        }

        case ProjectedGridGPUInterpolation:
        {
            [ cornerVertexArray renderWithPrimitiveType:NpPrimitiveTriangles ];
            break;
        }
    }
}

@end

