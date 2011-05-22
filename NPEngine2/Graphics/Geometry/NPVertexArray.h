#import "Core/Basics/NpTypes.h"
#import "Core/NPObject/NPObject.h"
#import "Graphics/NPEngineGraphicsEnums.h"
#import "GL/glew.h"

@class NSMutableArray;
@class NSError;
@class NPBufferObject;
@class NPCPUBuffer;

@interface NPVertexArray : NPObject
{
    GLuint glID;
    GLsizei numberOfVertices;
    GLsizei numberOfIndices;
    NSMutableArray * vertexStreams;
    NPBufferObject * indexStream;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (GLuint) glID;

- (BOOL) addVertexStream:(NPBufferObject *)vertexStream
              atLocation:(NpVertexStreamSemantic)location
                   error:(NSError **)error
                        ;

- (BOOL) addCPUVertexStream:(NPCPUBuffer *)vertexStream
                 atLocation:(NpVertexStreamSemantic)location
                      error:(NSError **)error
                           ;

- (BOOL) addIndexStream:(NPBufferObject *)newIndexStream
                  error:(NSError **)error
                       ;

- (void) renderWithPrimitiveType:(const NpPrimitveType)type;
- (void) renderWithPrimitiveType:(const NpPrimitveType)type
                      firstIndex:(const uint32_t)firstIndex
                       lastIndex:(const uint32_t)lastIndex
                                ;

@end

