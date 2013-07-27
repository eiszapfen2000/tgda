#import "NPTextureBuffer.h"

@implementation NPTextureBuffer

- (id) init
{
    return [ self initWithName:@"TextureBuffer" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    glGenTextures(1, &textureID);

    return self;
}

- (void) dealloc
{
    if (textureID > 0 )
    {
        glDeleteTextures(1, &textureID);
        textureID = 0;
    }

    [ super dealloc ];
}

- (NpTextureType) textureType
{
    return NpTextureTypeTextureBuffer;
}

- (GLuint) glID
{
    return textureID;
}

- (GLenum) glTarget
{
    return GL_TEXTURE_BUFFER;
}

@end

