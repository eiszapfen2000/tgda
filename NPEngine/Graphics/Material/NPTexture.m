#import "NPTexture.h"
#import "NPTextureManager.h"
#import "Graphics/Image/NPImage.h"
#import "Graphics/Image/NPImageManager.h"
#import "Core/NPEngineCore.h"

#import "IL/il.h"
#import "IL/ilu.h"
#import "IL/ilut.h"

void np_texture_filter_state_reset(NpTextureFilterState * textureFilterState)
{
    textureFilterState->mipmapping = NO;
    textureFilterState->minFilter = NP_TEXTURE_FILTER_NEAREST_MIPMAP_LINEAR;
    textureFilterState->magFilter = NP_TEXTURE_FILTER_LINEAR;
    textureFilterState->anisotropy = 1.0f;
}

void np_texture_wrap_state_reset(NpTextureWrapState * textureWrapState)
{
    textureWrapState->wrapS = NP_TEXTURE_WRAPPING_REPEAT;
    textureWrapState->wrapT = NP_TEXTURE_WRAPPING_REPEAT;
}

@implementation NPTexture

- (id) init
{
    return [ self initWithName:@"NPTexture" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    //equals opengl default states
    np_texture_filter_state_reset(&textureFilterState);
    np_texture_wrap_state_reset(&textureWrapState);

    image = nil;

    return self;
}

- (void) dealloc
{
    [ self reset ];    

    [ super dealloc ];
}

- (BOOL) loadFromFile:(NPFile *)file
{
    [ self reset ];

    [ self setFileName:[ file fileName ] ];
    [ self setName:[ file fileName ] ];

    [ self generateGLTextureID ];
    
    image = [[[NPEngineCore instance ] imageManager ] loadImageUsingFileHandle:file ];

    if ( image == nil )
    {
        return NO;
    }

    [ image retain ];

    [ self setupInternalFormat ];

    ready = YES;

	return YES;
}

- (void) reset
{
    glDeleteTextures(1, &textureID);

    np_texture_filter_state_reset(&textureFilterState);
    np_texture_wrap_state_reset(&textureWrapState);

    [ super reset ];
}

- (BOOL) isReady
{
    return ready;
}

- (UInt) textureID
{
    return textureID;
}

- (void) generateGLTextureID
{
    glGenTextures(1, &textureID);
}

- (void) activate
{

}

- (void) setupInternalFormat
{
    NPLOG(([NSString stringWithFormat:@"internal format %d", [image pixelFormat]]));

    switch ( [ image pixelFormat ] )
    {
        case NP_PIXELFORMAT_BYTE_R:{internalFormat = 1; break;}
        case NP_PIXELFORMAT_BYTE_RG:{internalFormat = 2; break;}
        case NP_PIXELFORMAT_BYTE_RGB:{internalFormat = GL_RGB8; break;}
        case NP_PIXELFORMAT_BYTE_RGBA:{internalFormat = GL_RGBA8; break;}
        case NP_PIXELFORMAT_FLOAT16_R:{internalFormat = 1; break;}
        case NP_PIXELFORMAT_FLOAT16_RG:{internalFormat = 2; break;}
        case NP_PIXELFORMAT_FLOAT16_RGB:{internalFormat = GL_RGB16F_ARB; break;}
        case NP_PIXELFORMAT_FLOAT16_RGBA:{internalFormat = GL_RGBA16F_ARB; break;}
        case NP_PIXELFORMAT_FLOAT32_R:{internalFormat = 1; break;}
        case NP_PIXELFORMAT_FLOAT32_RG:{internalFormat = 2; break;}
        case NP_PIXELFORMAT_FLOAT32_RGB:{internalFormat = GL_RGB32F_ARB; break;}
        case NP_PIXELFORMAT_FLOAT32_RGBA:{internalFormat = GL_RGBA32F_ARB; break;}
    }
}

- (void) setTextureFilterState:(NpTextureFilterState)newTextureFilterState
{
    textureFilterState = newTextureFilterState;
}

- (void) setMipMapping:(NPState)newMipMapping
{
    if ( textureFilterState.mipmapping != newMipMapping )
    {
        textureFilterState.mipmapping = newMipMapping;

        GLint value;
        switch ( newMipMapping )
        {
            case NP_TEXTURE_FILTER_MIPMAPPING_ACTIVE:{value = GL_TRUE; break;}
            case NP_TEXTURE_FILTER_MIPMAPPING_INACTIVE:{value = GL_FALSE; break;}
        }

        glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, value);
    }
}

- (void) setTextureMinFilter:(NPState)newTextureMinFilter
{
    if ( textureFilterState.minFilter != newTextureMinFilter )
    {
        textureFilterState.minFilter = newTextureMinFilter;

        GLint value;
        switch ( newTextureMinFilter )
        {
            case NP_TEXTURE_FILTER_NEAREST:{value = GL_NEAREST; break;}
            case NP_TEXTURE_FILTER_LINEAR:{value = GL_LINEAR; break;}
            case NP_TEXTURE_FILTER_NEAREST_MIPMAP_NEAREST:{value = GL_NEAREST_MIPMAP_NEAREST; break;}
            case NP_TEXTURE_FILTER_LINEAR_MIPMAP_NEAREST:{value = GL_LINEAR_MIPMAP_NEAREST; break;}
            case NP_TEXTURE_FILTER_NEAREST_MIPMAP_LINEAR:{value = GL_NEAREST_MIPMAP_LINEAR; break;}
            case NP_TEXTURE_FILTER_LINEAR_MIPMAP_LINEAR:{value = GL_LINEAR_MIPMAP_LINEAR; break;}
        }

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, value);       
    }
}

- (void) setTextureMaxFilter:(NPState)newTextureMagFilter
{
    if ( textureFilterState.magFilter != newTextureMagFilter )
    {
        textureFilterState.magFilter = newTextureMagFilter;

        GLint value;
        switch ( newTextureMagFilter )
        {
            case NP_TEXTURE_FILTER_NEAREST:{value = GL_NEAREST; break;}
            case NP_TEXTURE_FILTER_LINEAR:{value = GL_LINEAR; break;}
        }

        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, value);        
    }
}

- (void) setTextureAnisotropyFilter:(NPState)newTextureAnisotropyFilter
{
    if ( textureFilterState.anisotropy != newTextureAnisotropyFilter )
    {
        textureFilterState.anisotropy = newTextureAnisotropyFilter;

        GLfloat value;
        switch ( newTextureAnisotropyFilter )
        {
            case NP_TEXTURE_FILTER_ANISOTROPY_1X:{value = 1.0; break;}
            case NP_TEXTURE_FILTER_ANISOTROPY_2X:{value = 2.0; break;}
            case NP_TEXTURE_FILTER_ANISOTROPY_4X:{value = 4.0; break;}
            case NP_TEXTURE_FILTER_ANISOTROPY_8X:{value = 8.0; break;}
            case NP_TEXTURE_FILTER_ANISOTROPY_16X:{value = 16.0; break;}
        }

        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, value);
    }
}

- (void) setTextureWrapState:(NpTextureWrapState)newTextureWrapState
{
    textureWrapState = newTextureWrapState;
}

- (void) setTextureWrap:(NPState)textureCoordinate withValue:(NPState)newTextureWrapValue
{
    GLenum textureParameterValue;
    switch ( textureCoordinate )
    {
        case NP_TEXTURE_WRAP_S:{textureParameterValue = GL_TEXTURE_WRAP_S; break;}
        case NP_TEXTURE_WRAP_T:{textureParameterValue = GL_TEXTURE_WRAP_T; break;}
    }

    GLint wrapValue;
    switch (newTextureWrapValue)
    {
        case NP_TEXTURE_WRAPPING_CLAMP:{wrapValue = GL_CLAMP; break;}
        case NP_TEXTURE_WRAPPING_CLAMP_TO_EDGE:{wrapValue = GL_CLAMP_TO_EDGE; break;}
        case NP_TEXTURE_WRAPPING_CLAMP_TO_BORDER:{wrapValue = GL_CLAMP_TO_BORDER; break;}
        case NP_TEXTURE_WRAPPING_REPEAT:{wrapValue = GL_REPEAT; break;}
    }

    glTexParameteri(GL_TEXTURE_2D, textureParameterValue, wrapValue);
}

- (void) setTextureWrapS:(NPState)newWrapS
{
    if ( textureWrapState.wrapS != newWrapS )
    {
        textureWrapState.wrapS = newWrapS;

        [ self setTextureWrap:NP_TEXTURE_WRAP_S withValue:newWrapS ];
    }
}

- (void) setTextureWrapT:(NPState)newWrapT
{
    if ( textureWrapState.wrapT != newWrapT )
    {
        textureWrapState.wrapT = newWrapT;

        [ self setTextureWrap:NP_TEXTURE_WRAP_T withValue:newWrapT ];
    }
}

- (void) uploadToGL
{
    glBindTexture(GL_TEXTURE_2D, textureID);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, [image width], [image height], 0, GL_RGBA, GL_UNSIGNED_BYTE, [[image imageData] bytes]);
}

@end
