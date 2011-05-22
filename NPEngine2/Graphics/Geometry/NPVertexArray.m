#import <Foundation/NSArray.h>
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

    vertexStreams = [[ NSMutableArray alloc ] init ];
    indexStream = nil;

    return self;
}

- (void) dealloc
{
    if ( glID > 0 )
    {
        glDeleteVertexArrays(1, &glID);
    }

    [ vertexStreams removeAllObjects ];
    DESTROY(vertexStreams);

    SAFE_DESTROY(indexStream);

    [ super dealloc ];
}

- (GLuint) glID
{
    return glID;
}

- (BOOL) addVertexStream:(NPBufferObject *)vertexStream
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

    GLuint glLocation = (GLuint)location;
    GLenum type = getGLBufferDataFormat([ vertexStream dataFormat]);
    GLint size = (GLint)[ vertexStream numberOfComponents ];

    glBindVertexArray(glID);
    [ vertexStream activate ];
    glVertexAttribPointer(glLocation, size, type, GL_FALSE, 0, 0);
    [ vertexStream deactivate ];
    glEnableVertexAttribArray(glLocation);
    glBindVertexArray(0);

    return YES;
}

- (BOOL) addCPUVertexStream:(NPCPUBuffer *)vertexStream
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

    GLuint glLocation = (GLuint)location;
    GLenum type = getGLBufferDataFormat([ vertexStream dataFormat]);
    GLint size = (GLint)[ vertexStream numberOfComponents ];

    glBindVertexArray(glID);
    glVertexAttribPointer(glLocation, size, type, GL_FALSE, 0, [[ vertexStream data ] bytes ]);
    glEnableVertexAttribArray(glLocation);
    glBindVertexArray(0);

    return YES;
}

- (BOOL) addIndexStream:(NPBufferObject *)newIndexStream
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
        glDrawArrays(type, 0, lastIndex - firstIndex + 1);
        glBindVertexArray(0);
    } 
}


@end
