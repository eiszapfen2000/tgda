#import "Core/Basics/NpTypes.h"
#import "Core/NPObject/NPObject.h"
#import "Graphics/NPEngineGraphicsEnums.h"
#import "GL/glew.h"

@class NSPointerArray;
@class NSError;
@class NPBufferObject;
@class NPCPUBuffer;

@interface NPCPUVertexArray : NPObject
{
    GLsizei numberOfVertices;
    GLsizei numberOfIndices;
    NSPointerArray * vertexStreams;
    NPCPUBuffer * indexStream;

    GLenum  types[NpVertexStreamMax + 1];
    GLint   sizes[NpVertexStreamMax + 1];
    GLvoid* pointers[NpVertexStreamMax + 1];
    GLvoid* indexPointer;
    GLenum  indexType;
    GLsizei numberOfBytesForIndex;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (BOOL) setVertexStream:(NPCPUBuffer *)newVertexStream
              atLocation:(NpVertexStreamSemantic)location
                   error:(NSError **)error
                        ;

- (BOOL) setIndexStream:(NPCPUBuffer *)newIndexStream
                  error:(NSError **)error
                       ;

- (void) renderWithPrimitiveType:(const NpPrimitveType)type;
- (void) renderWithPrimitiveType:(const NpPrimitveType)type
                      firstIndex:(const uint32_t)firstIndex
                       lastIndex:(const uint32_t)lastIndex
                                ;

@end
