#import "Core/Basics/NpTypes.h"
#import "Core/NPObject/NPObject.h"
#import "Graphics/NPEngineGraphicsEnums.h"
#import "GL/glew.h"

@class NSPointerArray;
@class NSError;
@class NPBufferObject;

@interface NPVertexArray : NPObject
{
    GLuint glID;
    GLsizei numberOfVertices;
    GLsizei numberOfIndices;
    NSPointerArray * vertexStreams;
    NPBufferObject * indexStream;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (GLuint) glID;

- (BOOL) setVertexStream:(NPBufferObject *)newVertexStream
              atLocation:(NpVertexStreamSemantic)location
                   error:(NSError **)error
                        ;

- (BOOL) setIndexStream:(NPBufferObject *)newIndexStream
                  error:(NSError **)error
                       ;

- (void) renderWithPrimitiveType:(const NpPrimitveType)type;
- (void) renderWithPrimitiveType:(const NpPrimitveType)type
                      firstIndex:(const uint32_t)firstIndex
                       lastIndex:(const uint32_t)lastIndex
                                ;

@end

