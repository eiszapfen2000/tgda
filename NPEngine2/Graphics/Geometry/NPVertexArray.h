#import "Core/Basics/NpTypes.h"
#import "Core/NPObject/NPObject.h"
#import "Graphics/NPEngineGraphicsEnums.h"
#import "GL/glew.h"

@class NSMutableArray;
@class NSError;
@class NPBufferObject;

@interface NPVertexArray : NPObject
{
    GLuint glID;
    GLsizei numberOfVertices;
    NpPrimitveType primitiveType;
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

- (BOOL) addIndexStream:(NPBufferObject *)newIndexStream
                  error:(NSError **)error
                       ;

- (void) activate;
- (void) deactivate;

- (void) render;
- (void) renderWithPrimitiveType:(NpPrimitveType)type;

@end

