#import "GL/glew.h"
#import "Core/NPObject/NPObject.h"
#import "Graphics/NPEngineGraphicsEnums.h"
#import "NPPTexture.h"

@class NPBufferObject;

@interface NPTextureBuffer : NPObject < NPPTexture >
{
    GLuint textureID;
    NPBufferObject * buffer;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

@end


