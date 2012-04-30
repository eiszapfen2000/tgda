#import <Foundation/NSPointerArray.h>
#import <Foundation/NSData.h>
#import <Foundation/NSException.h>
#import "Log/NPLog.h"
#import "Graphics/Buffer/NPBufferObject.h"
#import "Graphics/Buffer/NPCPUBuffer.h"
#import "NPVertexArray.h"

@implementation NPVertexArray

- (id) init
{
    return [ self initWithName:@"Vertex Array" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    glGenVertexArrays(1, &glID);
    numberOfVertices = 0;
    numberOfIndices = 0;

    NSPointerFunctionsOptions options
        = NSPointerFunctionsObjectPointerPersonality | NSPointerFunctionsStrongMemory;

    vertexStreams = [[ NSPointerArray alloc ] initWithOptions:options ];
    [ vertexStreams setCount:(NpVertexStreamMax + 1) ];
    indexStream = nil;

    return self;
}

- (void) dealloc
{
    if ( glID > 0 )
    {
        glDeleteVertexArrays(1, &glID);
    }

    [ vertexStreams setCount:0 ];
    DESTROY(vertexStreams);
    SAFE_DESTROY(indexStream);

    [ super dealloc ];
}

- (GLuint) glID
{
    return glID;
}

- (BOOL) setVertexStream:(NPBufferObject *)newVertexStream
              atLocation:(NpVertexStreamSemantic)location
                   error:(NSError **)error
{
    if ( newVertexStream == nil )
    {
        [ vertexStreams replacePointerAtIndex:location withPointer:NULL ];
        glBindVertexArray(glID);
        glDisableVertexAttribArray((GLuint)location);
        glBindVertexArray(0);

        NSArray * streams = [ vertexStreams allObjects ];
        if ( [ streams count ] == 0 )
        {
            numberOfVertices = 0;
        }

        return YES;
    }

    NSUInteger numberOfElements = [ newVertexStream numberOfElements ];
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

    [ vertexStreams replacePointerAtIndex:location withPointer:newVertexStream ];

    GLuint glLocation = (GLuint)location;
    GLenum type = getGLBufferDataFormat([ newVertexStream dataFormat]);
    GLint size = (GLint)[ newVertexStream numberOfComponents ];

    glBindVertexArray(glID);
    [ newVertexStream activate ];
    glVertexAttribPointer(glLocation, size, type, GL_FALSE, 0, 0);
    [ newVertexStream deactivate ];
    glEnableVertexAttribArray(glLocation);
    glBindVertexArray(0);

    return YES;
}

- (BOOL) setIndexStream:(NPBufferObject *)newIndexStream
                  error:(NSError **)error
{
    SAFE_DESTROY(indexStream);
    numberOfIndices = 0;

    if ( newIndexStream == nil )
    {
        return YES;
    }

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
        glBindVertexArray(glID);
        [ indexStream activate ];

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

        glDrawRangeElements(type, 0, numberOfVertices - 1, lastIndex - firstIndex + 1,
            [ indexStream glDataFormat ], BUFFER_OFFSET(firstIndex*sizeof(uint32_t)));

#undef BUFFER_OFFSET

        [ indexStream deactivate ];
        glBindVertexArray(0);
    }
    else
    {
        glBindVertexArray(glID);
        glDrawArrays(type, firstIndex, lastIndex - firstIndex + 1);
        glBindVertexArray(0);
    } 
}


@end
