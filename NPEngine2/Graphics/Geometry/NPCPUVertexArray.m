#import <Foundation/NSArray.h>
#import <Foundation/NSData.h>
#import <Foundation/NSException.h>
#import "Log/NPLog.h"
#import "Graphics/Buffer/NPCPUBuffer.h"
#import "NPCPUVertexArray.h"

@implementation NPCPUVertexArray

- (id) init
{
    return [ self initWithName:@"CPU Vertex Array" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    numberOfVertices = 0;
    numberOfIndices = 0;

    vertexStreams = [[ NSMutableArray alloc ] init ];
    indexStream = nil;

    memset(types,    0, sizeof(types));
    memset(sizes,    0, sizeof(sizes));
    memset(pointers, 0, sizeof(pointers));
    indexPointer = NULL;
    indexType = GL_NONE;
    numberOfBytesForIndex = 0;

    return self;
}

- (void) dealloc
{
    [ vertexStreams removeAllObjects ];
    DESTROY(vertexStreams);

    SAFE_DESTROY(indexStream);

    [ super dealloc ];
}

- (BOOL) addVertexStream:(NPCPUBuffer *)vertexStream
              atLocation:(NpVertexStreamSemantic)location
                   error:(NSError **)error
{
    NSAssert(vertexStream != nil, @"Invalid vertex stream");

    NSUInteger numberOfElements = [ vertexStream numberOfElements ];
    if ( numberOfElements == 0 )
    {
        NPLOG(@"Empty Vertex Stream");
        return NO;
    }

    if ( numberOfElements > INT_MAX )
    {
        NPLOG(@"Vertex Stream is to large");
        return NO;
    }

    GLsizei glNumberOfElements = (GLsizei)numberOfElements;

    if ( numberOfVertices == 0 )
    {
        numberOfVertices = glNumberOfElements;
    }
    else if ( numberOfVertices != glNumberOfElements )
    {
        NPLOG(@"Buffer size mismatch");
        return NO;
    }

    [ vertexStreams addObject:vertexStream ];

    types[location] = getGLBufferDataFormat([ vertexStream dataFormat]);
    sizes[location] = (GLint)[ vertexStream numberOfComponents ];
    pointers[location] = (GLvoid *)[[ vertexStream data ] bytes ];

    return YES;
}

- (BOOL) addIndexStream:(NPCPUBuffer *)newIndexStream
                  error:(NSError **)error
{
    NSAssert(newIndexStream != nil, @"Invalid index stream");

    NSUInteger numberOfElements = [ newIndexStream numberOfElements ];
    if ( numberOfElements == 0 )
    {
        NPLOG(@"Empty Index Stream");
        return NO;
    }

    if ( numberOfElements > INT_MAX )
    {
        NPLOG(@"Index Stream is to large");
        return NO;
    }

    indexStream = RETAIN(newIndexStream);
    numberOfIndices = (GLsizei)numberOfElements;
    indexPointer = (GLvoid *)[[ indexStream data ] bytes ];
    indexType = getGLBufferDataFormat([ indexStream dataFormat ]);
    numberOfBytesForIndex
        = (GLsizei)numberOfBytesForDataFormat([ indexStream dataFormat ]);

    return YES;
}

- (void) renderWithPrimitiveType:(const NpPrimitveType)type
{
    if ( indexStream != nil )
    {
        [ self renderWithPrimitiveType:type
                            firstIndex:0
                             lastIndex:numberOfIndices - 1 ];

    }
    else
    {
        [ self renderWithPrimitiveType:type
                            firstIndex:0
                             lastIndex:numberOfVertices - 1 ];
    } 
}

- (void) renderWithPrimitiveType:(const NpPrimitveType)type
                      firstIndex:(const uint32_t)firstIndex
                       lastIndex:(const uint32_t)lastIndex
{
    if ( indexStream != nil )
    {
        for ( int32_t i = NpVertexStreamMin; i <= NpVertexStreamMax; i++ )
        {
            if ( pointers[i] != NULL )
            {
                glVertexAttribPointer(i, sizes[i], types[i], GL_FALSE, 0, pointers[i]);
                glEnableVertexAttribArray(i);
            }
        }

        glDrawRangeElements(type, 0, numberOfVertices - 1, lastIndex - firstIndex + 1,
            indexType, indexPointer + (firstIndex * numberOfBytesForIndex));

        for ( int32_t i = NpVertexStreamMin; i <= NpVertexStreamMax; i++ )
        {
            if ( pointers[i] != NULL )
            {
                glVertexAttribPointer(i, sizes[i], types[i], GL_FALSE, 0, NULL);
                glDisableVertexAttribArray(i);
            }
        }
    }
    else
    {
        for ( int32_t i = NpVertexStreamMin; i <= NpVertexStreamMax; i++ )
        {
            if ( pointers[i] != NULL )
            {
                glVertexAttribPointer(i, sizes[i], types[i], GL_FALSE, 0, pointers[i]);
                glEnableVertexAttribArray(i);
            }
        }

        glDrawArrays(type, 0, lastIndex - firstIndex + 1);

        for ( int32_t i = NpVertexStreamMin; i <= NpVertexStreamMax; i++ )
        {
            if ( pointers[i] != NULL )
            {
                glVertexAttribPointer(i, sizes[i], types[i], GL_FALSE, 0, NULL);
                glDisableVertexAttribArray(i);
            }
        }
    } 
}


@end
