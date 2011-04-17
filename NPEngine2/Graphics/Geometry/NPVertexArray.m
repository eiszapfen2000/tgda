#import <Foundation/NSArray.h>
#import <Foundation/NSException.h>
#import "Log/NPLog.h"
#import "Graphics/Buffer/NPBufferObject.h"
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
    primitiveType = NpPrimitiveUnknown;

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
    NSAssert(vertexStream != nil, @"");

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

- (BOOL) addIndexStream:(NPBufferObject *)newIndexStream
                  error:(NSError **)error
{
    NSAssert(newIndexStream != nil, @"");

    indexStream = RETAIN(newIndexStream);

    return YES;
}

- (void) activate
{
    glBindVertexArray(glID);
}

- (void) deactivate
{
    glBindVertexArray(0);
}

- (void) render
{
    [ self renderWithPrimitiveType:primitiveType ];
}

- (void) renderWithPrimitiveType:(NpPrimitveType)type
{
    if ( indexStream != nil )
    {
        glBindVertexArray(glID);
        [ indexStream activate ];
        glDrawElements(type, [ indexStream numberOfElements ], [ indexStream glDataFormat ], NULL);
        glBindVertexArray(0);
    }
    else
    {
        glBindVertexArray(glID);
        glDrawArrays(type, 0, numberOfVertices);
        glBindVertexArray(0);
    } 
}

@end
