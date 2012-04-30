#import <Foundation/NSArray.h>
#import <Foundation/NSData.h>
#import <Foundation/NSException.h>
#import "Log/NPLog.h"
#import "Core/Utilities/NSError+NPEngine.h"
#import "Graphics/NPEngineGraphicsErrors.h"
#import "Graphics/Buffer/NPCPUBuffer.h"
#import "NPCPUVertexArray.h"

static NSString * const NPCPUVertexArrayVertexStreamEmpty = @"Vertex stream is empty.";
static NSString * const NPCPUVertexArrayIndexStreamEmpty = @"Index stream is empty.";
static NSString * const NPCPUVertexArrayVertexStreamTooLarge = @"Vertex stream exceeds 2GB limit.";
static NSString * const NPCPUVertexArrayIndexStreamTooLarge = @"Index stream exceeds 2GB limit.";

static NSString * const NPCPUVertexArrayStreamMismatch
    = @"Stream has not the same number of vertices as other streams.";

@implementation NPCPUVertexArray

- (id) init
{
    return [ self initWithName:@"CPU Vertex Array" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    numberOfVertices = 0;
    numberOfIndices  = 0;

    vertexStreams = [[ NSMutableArray alloc ] initWithCapacity:(NpVertexStreamMax + 1) ];
    indexStream   = nil;

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

- (BOOL) setVertexStream:(NPCPUBuffer *)vertexStream
              atLocation:(NpVertexStreamSemantic)location
                   error:(NSError **)error
{
    NSAssert(vertexStream != nil, @"Invalid vertex stream");
    NSAssert([ vertexStream data ] != nil, @"Vertex stream has no data");

    const NSUInteger numberOfElements = [ vertexStream numberOfElements ];
    if ( numberOfElements == 0 )
    {
        if ( error != NULL )
        {
            *error
                = [ NSError errorWithCode:NPEngineGraphicsVertexArrayError
                              description:NPCPUVertexArrayVertexStreamEmpty ];
        }

        return NO;
    }

    if ( numberOfElements > INT_MAX )
    {
        if ( error != NULL )
        {
            *error
                = [ NSError errorWithCode:NPEngineGraphicsVertexArrayError
                              description:NPCPUVertexArrayVertexStreamTooLarge ];
        }

        return NO;
    }

    GLsizei glNumberOfElements = (GLsizei)numberOfElements;

    if ( numberOfVertices == 0 )
    {
        numberOfVertices = glNumberOfElements;
    }
    else if ( numberOfVertices != glNumberOfElements )
    {
        if ( error != NULL )
        {
            *error
                = [ NSError errorWithCode:NPEngineGraphicsVertexArrayError
                              description:NPCPUVertexArrayStreamMismatch ];
        }

        return NO;
    }

    [ vertexStreams addObject:vertexStream ];

    types[location] = getGLBufferDataFormat([ vertexStream dataFormat]);
    sizes[location] = (GLint)[ vertexStream numberOfComponents ];
    pointers[location] = (GLvoid *)[[ vertexStream data ] bytes ];

    return YES;
}

- (BOOL) setIndexStream:(NPCPUBuffer *)newIndexStream
                  error:(NSError **)error
{
    // release current strea, and reset data
    SAFE_DESTROY(indexStream);
    numberOfIndices = 0;
    indexPointer = NULL;
    indexType = GL_NONE;
    numberOfBytesForIndex = 0;

    // if no new index stream is provided, return
    if (newIndexStream == nil)
    {
        return YES;
    }

    // check for valid number of indices
    NSUInteger numberOfElements = [ newIndexStream numberOfElements ];
    if ( numberOfElements == 0 )
    {
        if ( error != NULL )
        {
            *error
                = [ NSError errorWithCode:NPEngineGraphicsVertexArrayError
                              description:NPCPUVertexArrayIndexStreamEmpty ];
        }

        return NO;
    }

    if ( numberOfElements > INT_MAX )
    {
        if ( error != NULL )
        {
            *error
                = [ NSError errorWithCode:NPEngineGraphicsVertexArrayError
                              description:NPCPUVertexArrayIndexStreamTooLarge ];
        }

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

        // this is necessary because arithmetic on void* is undefined
        unsigned char * ptr
            = ((unsigned char *)indexPointer) + (firstIndex * numberOfBytesForIndex);

        glDrawRangeElements(type, 0, numberOfVertices - 1, lastIndex - firstIndex + 1,
            indexType, ptr);

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
