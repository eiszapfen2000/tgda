#import <Foundation/NSData.h>
#import <Foundation/NSDictionary.h>
#import "Graphics/Buffer/NPCPUBuffer.h"
#import "Graphics/Geometry/NPCPUVertexArray.h"
#import "ODProjectedGrid.h"

@interface ODProjectedGrid (Private)

- (void) updateResolution;

@end

@implementation ODProjectedGrid (Private)

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
            nearPlanePostProjectionPositions[index].z = -1.0f;
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

    NSData * vertexData
        = [ NSData dataWithBytesNoCopy:nearPlanePostProjectionPositions
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

    fplane_pssss_init_with_components(&basePlane, 0.0f, 1.0f, 0.0f, 0.0f);

    vertexStream = [[ NPCPUBuffer alloc ] init ];
    indexStream  = [[ NPCPUBuffer alloc ] init ];
    vertexArray  = [[ NPCPUVertexArray alloc ] init ];

    return self;
}

- (void) dealloc
{
    DESTROY(vertexArray);
    DESTROY(vertexStream);
    DESTROY(indexStream);

    SAFE_FREE(nearPlanePostProjectionPositions);
    SAFE_FREE(worldSpacePositions);
    SAFE_FREE(indices);   

    [ super dealloc ];
}

- (BOOL) loadFromDictionary:(NSDictionary *)config
                      error:(NSError **)error
{
    if ( error != NULL )
    {
        *error = nil;
    }

    return NO;
}

- (void) update:(const float)frameTime
{
    if ( resolutionLastFrame.x != resolution.x
        || resolutionLastFrame.y != resolution.y )
    {
        [ self updateResolution ];

        resolutionLastFrame = resolution;
    }
}

- (void) render
{
}

@end
