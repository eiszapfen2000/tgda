#import "Foundation/NSData.h"
#import "Foundation/NSException.h"
#import "Graphics/Buffer/NPBufferObject.h"
#import "Graphics/Geometry/NPVertexArray.h"
#import "ODOceanBaseMesh.h"

@implementation ODOceanBaseMesh

- (id) init
{
    return [ self initWithName:@"ODOceanBaseMesh" ];
}

- (id) initWithName:(NSString *)newName
{
    self =  [ super initWithName:newName ];

    xzStream           = [[ NPBufferObject alloc ] initWithName:@"XZ Stream" ];
    yStream            = [[ NPBufferObject alloc ] initWithName:@"Y Stream"  ];
    supplementalStream = [[ NPBufferObject alloc ] initWithName:@"Gradients and Displacement" ];
    indexStream        = [[ NPBufferObject alloc ] initWithName:@"Indices"   ];

    mesh = [[ NPVertexArray alloc ] initWithName:@"Mesh" ];

    center.x = center.y = center.z = 0.0f;

    return self;
}

- (void) dealloc
{
    DESTROY(mesh);
    DESTROY(indexStream);
    DESTROY(supplementalStream);
    DESTROY(yStream);
    DESTROY(xzStream);

    [ super dealloc ];
}

- (FVector3) center
{
    return center;
}

- (NPBufferObject *) yStream
{
    return yStream;
}

- (NPBufferObject *) supplementalStream
{
    return supplementalStream;
}

- (BOOL) generateWithResolution:(int32_t)resolution
{
    NSAssert(resolution > 0, @"");

    const uint32_t numberOfVertices = resolution * resolution;
    const uint32_t numberOfTriangles = (resolution - 1) * (resolution - 1) * 2;
    const uint32_t numberOfIndices = numberOfTriangles * 3;

    FVector2 * vertices = ALLOC_ARRAY(FVector2, numberOfVertices);
    uint32_t * indices  = ALLOC_ARRAY(uint32_t, numberOfIndices);

    for ( int32_t i = 0; i < resolution; i++ )
    {
        for ( int32_t j = 0; j < resolution; j++ )
        {
            vertices[i*resolution + j] = (FVector2){.x = j, .y = i};
        }
    }

    center.x = center.z = (float)(resolution - 1) / 2.0f;

    int32_t index = 0;

    for ( int32_t i = 0; i < resolution - 1; i++ )
    {
        for ( int32_t j = 0; j < resolution - 1; j++ )
        {
            indices[index++] = (i*resolution) + j;
            indices[index++] = ((i+1)*resolution) + j;
            indices[index++] = ((i+1)*resolution) + j + 1;

            indices[index++] = ((i+1)*resolution) + j + 1;
            indices[index++] = (i*resolution) + j + 1;
            indices[index++] = (i*resolution) + j;
        }
    }

    NSData * xzData
        = [ NSData dataWithBytesNoCopy:vertices
                                length:numberOfVertices * sizeof(FVector2)
                          freeWhenDone:NO ];

    NSData * emptyData = [ NSData data ];

    NSData * indexData
        = [ NSData dataWithBytesNoCopy:indices
                                length:numberOfIndices * sizeof(uint32_t)
                          freeWhenDone:NO ];

    BOOL success
        = [ xzStream generate:NpBufferObjectTypeGeometry
                   updateRate:NpBufferDataUpdateOnceUseOften
                    dataUsage:NpBufferDataWriteCPUToGPU
                   dataFormat:NpBufferDataFormatFloat32
                   components:2
                         data:xzData
                   dataLength:[xzData length]
                        error:NULL ];

    success
        = success && [ yStream generate:NpBufferObjectTypeGeometry
                             updateRate:NpBufferDataUpdateOnceUseOften
                              dataUsage:NpBufferDataWriteCPUToGPU
                             dataFormat:NpBufferDataFormatFloat32
                             components:1
                                   data:emptyData
                             dataLength:numberOfVertices * sizeof(float)
                                  error:NULL ];

    success
        = success && [ supplementalStream generate:NpBufferObjectTypeGeometry
                                        updateRate:NpBufferDataUpdateOnceUseOften
                                         dataUsage:NpBufferDataWriteCPUToGPU
                                        dataFormat:NpBufferDataFormatFloat32
                                        components:4
                                              data:emptyData
                                        dataLength:numberOfVertices * sizeof(FVector4)
                                             error:NULL ];

    success
        = success && [ indexStream generate:NpBufferObjectTypeIndices
                                 updateRate:NpBufferDataUpdateOnceUseOften
                                  dataUsage:NpBufferDataWriteCPUToGPU
                                 dataFormat:NpBufferDataFormatUInt32
                                 components:1
                                       data:indexData
                                 dataLength:[indexData length]
                                      error:NULL ];

    success
        = success && [ mesh setVertexStream:xzStream
                                 atLocation:NpVertexStreamAttribute0
                                      error:NULL ];

    success
        = success && [ mesh setVertexStream:yStream
                                 atLocation:NpVertexStreamAttribute1
                                      error:NULL ];

    success
        = success && [ mesh setVertexStream:supplementalStream
                                 atLocation:NpVertexStreamAttribute2
                                      error:NULL ];

    success
        = success && [ mesh setIndexStream:indexStream
                                     error:NULL ];
    
    FREE(vertices);
    FREE(indices);

    return success;
}

- (void) updateYStream:(NSData *)yData
    supplementalStream:(NSData *)supplementalData
{
    NSAssert(yData != nil && supplementalData != nil, @"");

    [ yStream generate:NpBufferObjectTypeGeometry
            updateRate:NpBufferDataUpdateOnceUseOften
             dataUsage:NpBufferDataWriteCPUToGPU
            dataFormat:NpBufferDataFormatFloat32
            components:1
                  data:yData
            dataLength:[yData length]
                 error:NULL ];

    [ supplementalStream generate:NpBufferObjectTypeGeometry
                       updateRate:NpBufferDataUpdateOnceUseOften
                        dataUsage:NpBufferDataWriteCPUToGPU
                       dataFormat:NpBufferDataFormatFloat32
                       components:4
                             data:supplementalData
                       dataLength:[supplementalData length]
                            error:NULL ];
}

- (void) render
{
    [ mesh renderWithPrimitiveType:NpPrimitiveTriangles ];
}

@end

