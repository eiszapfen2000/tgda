#import <Foundation/NSArray.h>
#import <Foundation/NSData.h>
#import <Foundation/NSException.h>
#import "Log/NPLog.h"
#import "Core/Utilities/NSError+NPEngine.h"
#import "Core/NPEngineCore.h"
#import "Graphics/Buffer/NPBufferObject.h"
#import "Graphics/Geometry/NPVertexArray.h"
#import "NPSUX2VertexBuffer.h"

#define SUX2_SAMPLER_COUNT 8

typedef struct NpSUX2VertexFormat
{
    int32_t elementsForPosition;
    int32_t elementsForNormal;
    int32_t elementsForColor;
    int32_t elementsForWeights;
    int32_t elementsForTextureCoordinateSet[SUX2_SAMPLER_COUNT];
    int32_t maxTextureCoordinateSet;
}
NpSUX2VertexFormat;

typedef struct NpSUX2Vertices
{
    NpSUX2VertexFormat format;
    int32_t primitiveType;
    BOOL indexed;

    float * positions;
    float * normals;
    float * colors;
    float * weights;
    float * textureCoordinates[SUX2_SAMPLER_COUNT];

    int32_t * indices;
    int32_t maxVertex;
    int32_t maxIndex;
}
NpSUX2Vertices;

void init_vertexformat(NpSUX2VertexFormat * vertexformat)
{
    memset(vertexformat, 0, sizeof(NpSUX2VertexFormat));
    vertexformat->elementsForPosition = 3;
}

void init_vertices(NpSUX2Vertices * vertices)
{
    init_vertexformat(&(vertices->format));

    vertices->primitiveType = 0;
    vertices->positions     = NULL;
    vertices->normals       = NULL;
    vertices->colors        = NULL;
    vertices->weights       = NULL;
    vertices->indices       = NULL;
    vertices->indexed       = NO;
    vertices->maxVertex     = 0;
    vertices->maxIndex      = 0;

    for ( int32_t i = 0; i < SUX2_SAMPLER_COUNT; i++ )
    {
        vertices->textureCoordinates[i] = NULL;
    }
}

void vertices_allocate_storage(NpSUX2Vertices * vertices, const int32_t numberOfVertices,
        const int32_t numberOfIndices)
{
    assert(vertices != NULL);
    assert(numberOfVertices > 0);

    vertices->maxVertex = numberOfVertices - 1;
    vertices->maxIndex  = MAX(0, numberOfIndices  - 1);

    vertices->positions = ALLOC_ARRAY(float, 3 * numberOfVertices);

    if ( vertices->format.elementsForNormal > 0 )
    {
        vertices->normals
            = ALLOC_ARRAY(float, vertices->format.elementsForNormal * numberOfVertices);
    }

    if ( vertices->format.elementsForColor > 0 )
    {
        vertices->colors
            = ALLOC_ARRAY(float, vertices->format.elementsForColor * numberOfVertices);
    }

    if ( vertices->format.elementsForWeights > 0 )
    {
        vertices->weights
            = ALLOC_ARRAY(float, vertices->format.elementsForWeights * numberOfVertices);
    }

    for ( int32_t i = 0; i < SUX2_SAMPLER_COUNT; i++ )
    {
        if ( vertices->format.elementsForTextureCoordinateSet[i] > 0 )
        {
            vertices->textureCoordinates[i]
                = ALLOC_ARRAY(float, vertices->format.elementsForTextureCoordinateSet[i] * numberOfVertices);
        }
    }

    if ( vertices->maxIndex > 0 )
    {
        vertices->indices = ALLOC_ARRAY(int32_t, numberOfIndices);
    }
}

void vertices_delete_storage(NpSUX2Vertices * vertices)
{
    assert(vertices != NULL);

    SAFE_FREE(vertices->positions);
    SAFE_FREE(vertices->normals);
    SAFE_FREE(vertices->colors);
    SAFE_FREE(vertices->weights);
    SAFE_FREE(vertices->indices);

    for ( int32_t i = 0; i < SUX2_SAMPLER_COUNT; i++ )
    {
        SAFE_FREE(vertices->textureCoordinates[i]);
    }

    vertices->maxVertex = 0;
    vertices->maxIndex  = 0;
}

@interface NPSUX2VertexBuffer (Private)

- (NPBufferObject *) bufferObjectForBytes:(void *)bytes
                       numberOfComponents:(uint32_t)numberOfComponents
                            numberOfBytes:(size_t)numberOfBytes
                                         ;

- (NPBufferObject *) bufferObjectForIndices:(int32_t *)indices
                            numberOfIndices:(size_t)numberOfIndices
                                           ;


- (void) createVertexArrayUsingVertices:(NpSUX2Vertices *)vertices;

@end

@implementation NPSUX2VertexBuffer (Private)

- (NPBufferObject *) bufferObjectForBytes:(void *)bytes
                       numberOfComponents:(uint32_t)numberOfComponents
                            numberOfBytes:(size_t)numberOfBytes
{
    NSData * data
        = [ NSData dataWithBytesNoCopy:bytes 
                                length:numberOfBytes
                          freeWhenDone:NO ];

    NPBufferObject * bo = [[ NPBufferObject alloc ] init ];

    if ( [ bo generate:NpBufferObjectTypeGeometry
            updateRate:NpBufferDataUpdateOnceUseOften
             dataUsage:NpBufferDataWriteCPUToGPU
            dataFormat:NpBufferDataFormatFloat32
            components:numberOfComponents
                  data:data
            dataLength:numberOfBytes
                 error:NULL ] == NO )
    {
        NPLOG(@"KABRAK");
    }

    return AUTORELEASE(bo);
}

- (NPBufferObject *) bufferObjectForIndices:(int32_t *)indices
                            numberOfIndices:(size_t)numberOfIndices
{
    NSData * data
        = [ NSData dataWithBytesNoCopy:indices 
                                length:numberOfIndices * sizeof(int32_t)
                          freeWhenDone:NO ];

    NPBufferObject * bo = [[ NPBufferObject alloc ] init ];

    if ( [ bo generate:NpBufferObjectTypeIndices
            updateRate:NpBufferDataUpdateOnceUseOften
             dataUsage:NpBufferDataWriteCPUToGPU
            dataFormat:NpBufferDataFormatUInt32
            components:1
                  data:data
            dataLength:[ data length ]
                 error:NULL ] == NO )
    {
        NPLOG(@"IKABRAK");
    }

    return AUTORELEASE(bo);
}

- (void) createVertexArrayUsingVertices:(NpSUX2Vertices *)vertices
{
    NSAssert(vertices != NULL, @"vertices is NULL");

    SAFE_DESTROY(vertexArray);
    vertexArray = [[ NPVertexArray alloc ] init ];

    size_t numberOfVertices = vertices->maxVertex + 1;

    NPBufferObject * bufferObject
        =[ self bufferObjectForBytes:vertices->positions
                  numberOfComponents:3
                       numberOfBytes:numberOfVertices * sizeof(float) * 3 ];

    [ vertexArray addVertexStream:bufferObject atLocation:NpVertexStreamPositions error:NULL ];

    if ( vertices->format.elementsForNormal > 0 )
    {
        bufferObject
            = [ self bufferObjectForBytes:vertices->normals
                       numberOfComponents:vertices->format.elementsForNormal
                            numberOfBytes:vertices->format.elementsForNormal * numberOfVertices * sizeof(float) ];

            [ vertexArray addVertexStream:bufferObject atLocation:NpVertexStreamNormals error:NULL ];
    }

    if ( vertices->format.elementsForColor > 0 )
    {
        bufferObject
            = [ self bufferObjectForBytes:vertices->colors
                       numberOfComponents:vertices->format.elementsForColor
                            numberOfBytes:vertices->format.elementsForColor * numberOfVertices * sizeof(float) ];

            [ vertexArray addVertexStream:bufferObject atLocation:NpVertexStreamColors error:NULL ];
    }

    if ( vertices->format.elementsForWeights > 0 )
    {

    }

    for ( int32_t i = 0; i < SUX2_SAMPLER_COUNT; i++ )
    {
        if ( vertices->format.elementsForTextureCoordinateSet[i] > 0 )
        {
            bufferObject
                = [ self bufferObjectForBytes:vertices->textureCoordinates[i]
                           numberOfComponents:vertices->format.elementsForTextureCoordinateSet[i]
                                numberOfBytes:vertices->format.elementsForTextureCoordinateSet[i] * numberOfVertices * sizeof(float) ];

            [ vertexArray addVertexStream:bufferObject atLocation:NpVertexStreamTexCoords0 + i error:NULL ];
        }
    }

    if ( vertices->indexed == YES )
    {
        bufferObject
            = [ self bufferObjectForIndices:vertices->indices
                            numberOfIndices:vertices->maxIndex + 1 ];

        [ vertexArray addIndexStream:bufferObject error:NULL ];
    }
}

@end

@implementation NPSUX2VertexBuffer

- (id) init
{
    return [ self initWithName:@"SUX2 Vertex Buffer" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    file = nil;
    ready = NO;
    vertexArray = nil;

    return self;
}

- (void) dealloc
{
    SAFE_DESTROY(vertexArray);

    [ super dealloc ];
}

- (NSString *) fileName
{
    return file;
}

- (BOOL) ready
{
    return ready;
}

- (BOOL) loadFromStream:(id <NPPStream>)stream 
                  error:(NSError **)error
{
    NSAssert(stream != nil, @"");

    NpSUX2Vertices vertices;
    init_vertices(&vertices);

    int32_t vertexCount = 0;
    int32_t indexCount  = 0;

    [ stream readInt32:&(vertices.format.elementsForNormal) ];
    [ stream readInt32:&(vertices.format.elementsForColor)  ];
    [ stream readInt32:&(vertices.format.elementsForWeights)];

    for ( int32_t i = 0; i < SUX2_SAMPLER_COUNT; i++ )
    {
        [ stream readInt32:&(vertices.format.elementsForTextureCoordinateSet[i]) ];
    }

    [ stream readInt32:&(vertices.format.maxTextureCoordinateSet) ];
    [ stream readBool:&(vertices.indexed) ];
    [ stream readInt32:&vertexCount ];

    if ( vertices.indexed == YES )
    {
        [ stream readInt32:&indexCount ];
    }

    vertices_allocate_storage(&vertices, vertexCount, indexCount);

    [ stream readElementsToBuffer:vertices.positions
                      elementSize:sizeof(float)
                 numberOfElements:vertexCount * 3 ];

    if ( vertices.format.elementsForNormal > 0 )
    {
        [ stream readElementsToBuffer:vertices.normals
                          elementSize:sizeof(float)
                     numberOfElements:(vertexCount*vertices.format.elementsForNormal) ];
    }

    if ( vertices.format.elementsForColor > 0 )
    {
        [ stream readElementsToBuffer:vertices.colors
                          elementSize:sizeof(float)
                     numberOfElements:(vertexCount*vertices.format.elementsForColor) ];
    }

    if ( vertices.format.elementsForWeights > 0 )
    {
        [ stream readElementsToBuffer:vertices.weights
                          elementSize:sizeof(float)
                     numberOfElements:(vertexCount*vertices.format.elementsForWeights) ];
    }

    for ( int32_t i = 0; i < SUX2_SAMPLER_COUNT; i++ )
    {
        if ( vertices.format.elementsForTextureCoordinateSet[i] > 0 )
        {
            [ stream readElementsToBuffer:vertices.textureCoordinates[i]
                              elementSize:sizeof(float)
                         numberOfElements:(vertexCount * vertices.format.elementsForTextureCoordinateSet[i]) ];
        }
    }

    if ( vertices.indexed == YES )
    {
        [ stream readElementsToBuffer:vertices.indices
                          elementSize:sizeof(int32_t)
                     numberOfElements:indexCount ];
    }

    [ self createVertexArrayUsingVertices:&vertices ];

    vertices_delete_storage(&vertices);

    return YES;
}

- (BOOL) loadFromFile:(NSString *)fileName
            arguments:(NSDictionary *)arguments
                error:(NSError **)error
{
    return NO;
}

- (void) renderWithPrimitiveType:(const NpPrimitveType)primitveType
                      firstIndex:(const int32_t)firstIndex
                       lastIndex:(const int32_t)lastIndex
{
    [ vertexArray renderWithPrimitiveType:primitveType
                               firstIndex:(uint32_t)firstIndex
                                lastIndex:(uint32_t)lastIndex ];
}

@end
