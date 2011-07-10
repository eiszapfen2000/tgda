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

- (void) computeBasePlaneGeometry;
- (FVector4) computeBasePlanePosition:(const FVector2)postProjectionVertex;
- (void) computeBasePlaneBoundaryVertices;
- (void) updateResolution;

@end

@implementation ODProjectedGrid (Private)

- (void) computeBasePlaneGeometry
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

- (void) computeBasePlaneBoundaryVertices
{
    const FVector2 upperLeft  = {-1.0f,  1.0f};
    const FVector2 upperRight = { 1.0f,  1.0f};
    const FVector2 lowerLeft  = {-1.0f, -1.0f};
    const FVector2 lowerRight = { 1.0f, -1.0f};

    boundaryVertices[0] = [ self computeBasePlanePosition:lowerLeft  ];
    boundaryVertices[1] = [ self computeBasePlanePosition:lowerRight ];
    boundaryVertices[2] = [ self computeBasePlanePosition:upperRight ];
    boundaryVertices[3] = [ self computeBasePlanePosition:upperLeft  ];
}

- (void) updateResolution
{
    SAFE_FREE(nearPlanePostProjectionPositions);
    SAFE_FREE(worldSpacePositions);
    SAFE_FREE(indices);

    const size_t numberOfVertices = resolution.x * resolution.y;
    const size_t numberOfIndices
        = (resolution.x - 1) * (resolution.y - 1) * 6;

    nearPlanePostProjectionPositions = ALLOC_ARRAY(FVertex4, numberOfVertices);
    worldSpacePositions = ALLOC_ARRAY(FVertex4, numberOfVertices);
    indices = ALLOC_ARRAY(uint16_t, numberOfIndices);

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

            indices[quadrangleIndex]   = subIndex0;
            indices[quadrangleIndex+1] = subIndex1;
            indices[quadrangleIndex+2] = subIndex2;

            indices[quadrangleIndex+3] = subIndex2;
            indices[quadrangleIndex+4] = subIndex3;
            indices[quadrangleIndex+5] = subIndex0;
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
        = [ NSData dataWithBytesNoCopy:indices
                                length:sizeof(uint16_t) * numberOfIndices
                          freeWhenDone:NO ];

    BOOL result
        = [ vertexStream generate:NpBufferObjectTypeGeometry
                       dataFormat:NpBufferDataFormatFloat32
                       components:4
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

    SAFE_DESTROY(vertexArray);
    vertexArray = [[ NPCPUVertexArray alloc ] init ];

    result = [ vertexArray addVertexStream:vertexStream 
                                atLocation:NpVertexStreamPositions
                                     error:NULL ];

    NSAssert(result, @"");

    result = [ vertexArray addIndexStream:indexStream 
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

    vertexStream = [[ NPCPUBuffer alloc ] init ];
    indexStream  = [[ NPCPUBuffer alloc ] init ];

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
    SAFE_DESTROY(vertexArray);
    DESTROY(vertexStream);
    DESTROY(indexStream);

    SAFE_DESTROY(projector);

    SAFE_FREE(nearPlanePostProjectionPositions);
    SAFE_FREE(worldSpacePositions);
    SAFE_FREE(indices);   

    [ super dealloc ];
}

- (IVector2) resolution
{
    return resolution;
}

- (void) setResolution:(const IVector2)newResolution
{
    resolution = newResolution;
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

    [ self computeBasePlaneGeometry ];
    [ self computeBasePlaneBoundaryVertices ];
}

- (void) render
{
    [[[ NPEngineCore instance ] transformationState ] resetModelMatrix ];

    [ color setValue:gridColor ];
    [[ effect techniqueWithName:@"color" ] activate ];
    [ vertexArray renderWithPrimitiveType:NpPrimitiveTriangles ];
}

@end
