#import <Foundation/NSArray.h>
#import <Foundation/NSData.h>
#import <Foundation/NSException.h>
#import <Foundation/NSPointerArray.h>
#import "Log/NPLog.h"
#import "Core/Utilities/NSError+NPEngine.h"
#import "Graphics/NPEngineGraphicsErrors.h"
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
    numberOfIndices  = 0;

    NSPointerFunctionsOptions options
        = NSPointerFunctionsObjectPointerPersonality | NSPointerFunctionsStrongMemory;

    vertexStreams = [[ NSPointerArray alloc ] initWithOptions:options ];
    [ vertexStreams setCount:(NpVertexStreamMax + 1) ];
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
    [ vertexStreams setCount:0 ];
    DESTROY(vertexStreams);
    SAFE_DESTROY(indexStream);

    [ super dealloc ];
}

- (BOOL) setVertexStream:(NPCPUBuffer *)newVertexStream
              atLocation:(NpVertexStreamSemantic)location
                   error:(NSError **)error
{
    // release current stream, and reset data
    [ vertexStreams replacePointerAtIndex:location withPointer:NULL ];

    types[location] = GL_NONE;
    sizes[location] = 0;
    pointers[location] = NULL;

    NSArray * streams = [ vertexStreams allObjects ];
    if ( [ streams count ] == 0 )
    {
        numberOfVertices = 0;
    }

    // if no new vertex stream is provided, return
    if ( newVertexStream == nil )
    {
        return YES;
    }

    NSAssert([ newVertexStream data ] != nil, @"Vertex stream has no data");

    const NSUInteger numberOfElements = [ newVertexStream numberOfElements ];
    if ( numberOfElements == 0 )
    {
        if ( error != NULL )
        {
            *error
                = [ NSError errorWithCode:NPEngineGraphicsVertexArrayError
                              description:NPVertexArrayVertexStreamEmpty ];
        }

        return NO;
    }

    if ( numberOfElements > INT_MAX )
    {
        if ( error != NULL )
        {
            *error
                = [ NSError errorWithCode:NPEngineGraphicsVertexArrayError
                              description:NPVertexArrayVertexStreamTooLarge ];
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
                              description:NPVertexArrayStreamMismatch ];
        }

        return NO;
    }

    [ vertexStreams replacePointerAtIndex:location withPointer:newVertexStream ];

    types[location] = getGLBufferDataFormat([ newVertexStream dataFormat]);
    sizes[location] = (GLint)[ newVertexStream numberOfComponents ];
    pointers[location] = (GLvoid *)[[ newVertexStream data ] bytes ];

    return YES;
}

- (BOOL) setIndexStream:(NPCPUBuffer *)newIndexStream
                  error:(NSError **)error
{
    // release current stream, and reset data
    SAFE_DESTROY(indexStream);
    numberOfIndices = 0;
    indexPointer = NULL;
    indexType = GL_NONE;
    numberOfBytesForIndex = 0;

    // if no new index stream is provided, return
    if ( newIndexStream == nil )
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
                              description:NPVertexArrayIndexStreamEmpty ];
        }

        return NO;
    }

    if ( numberOfElements > INT_MAX )
    {
        if ( error != NULL )
        {
            *error
                = [ NSError errorWithCode:NPEngineGraphicsVertexArrayError
                              description:NPVertexArrayIndexStreamTooLarge ];
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
