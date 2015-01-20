#import <Foundation/NSException.h>
#import "Graphics/NPEngineGraphics.h"
#import "Graphics/Buffer/NPBufferObject.h"
#import "NPTextureBindingState.h"
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
    buffer = nil;

    return self;
}

- (void) dealloc
{
    [ self detachBuffer ];

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

- (void) attachBuffer:(NPBufferObject *)newBuffer
     numberOfElements:(NSUInteger)newNumberOfElements
          pixelFormat:(NpTexturePixelFormat)newPixelFormat
           dataFormat:(NpTextureDataFormat)newDataFormat
{
    NSAssert(newBuffer != nil, @"");
    ASSIGN(buffer, newBuffer);

    GLint glInternalFormat
        = getGLTextureInternalFormat(newDataFormat, newPixelFormat, YES,
                                     NULL, NULL);

    GLuint bufferID = [ buffer glID ];
    glBindBuffer(GL_TEXTURE_BUFFER, bufferID);

    [[[ NPEngineGraphics instance ] textureBindingState ] setTextureImmediately:self ];
    glTexBuffer(GL_TEXTURE_BUFFER, glInternalFormat, bufferID);
    [[[ NPEngineGraphics instance ] textureBindingState ] restoreOriginalTextureImmediately ];

    glBindBuffer(GL_TEXTURE_BUFFER, 0);
}

- (void) detachBuffer
{
    if ( buffer != nil )
    {
        [[[ NPEngineGraphics instance ] textureBindingState ] setTextureImmediately:self ];
        glTexBuffer(GL_TEXTURE_BUFFER, GL_NONE, 0);
        [[[ NPEngineGraphics instance ] textureBindingState ] restoreOriginalTextureImmediately ];

        DESTROY(buffer);
    }
}

@end

