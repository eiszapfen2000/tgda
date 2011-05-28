#import "Core/Basics/NpTypes.h"
#import "Core/NPObject/NPObject.h"
#import "Graphics/NPEngineGraphicsEnums.h"
#import "GL/glew.h"

@class NSMutableArray;
@class NSError;
@class NPBufferObject;
@class NPCPUBuffer;

@interface NPCPUVertexArray : NPObject
{
    GLsizei numberOfVertices;
    GLsizei numberOfIndices;
    NSMutableArray * vertexStreams;
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

- (BOOL) addVertexStream:(NPCPUBuffer *)vertexStream
              atLocation:(NpVertexStreamSemantic)location
                   error:(NSError **)error
                        ;

- (BOOL) addIndexStream:(NPCPUBuffer *)newIndexStream
                  error:(NSError **)error
                       ;

- (void) renderWithPrimitiveType:(const NpPrimitveType)type;
- (void) renderWithPrimitiveType:(const NpPrimitveType)type
                      firstIndex:(const uint32_t)firstIndex
                       lastIndex:(const uint32_t)lastIndex
                                ;

@end
