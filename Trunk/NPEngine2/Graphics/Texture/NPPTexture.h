#import "GL/glew.h"
#import "Graphics/NPEngineGraphicsEnums.h"

@protocol NPPTexture

- (NpTextureType) textureType;
- (GLuint) glID;
- (GLenum) glTarget;

@end

