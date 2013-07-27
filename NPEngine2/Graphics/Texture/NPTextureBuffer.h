#import "GL/glew.h"
#import "Core/NPObject/NPObject.h"
#import "Graphics/NPEngineGraphicsEnums.h"
#import "NPPTexture.h"

@interface NPTextureBuffer : NPObject < NPPTexture >
{
    GLuint textureID;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

@end


