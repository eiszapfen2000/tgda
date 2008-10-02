#import "NPTexture.h"
#import "NPTextureManager.h"
#import "Graphics/Image/NPImage.h"
#import "Graphics/Image/NPImageManager.h"
#import "Graphics/RenderContext/NPOpenGLRenderContext.h"
#import "Graphics/RenderContext/NPOpenGLRenderContextManager.h"
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

    dataFormat = NP_NONE;
    pixelFormat = NP_NONE;

    width = height = -1;

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
    
    NPImage * image = [[ NPImage alloc ] init ];
    if ( [ image loadFromFile:file ] == NO )
    {
        return NO;
    }

    dataFormat = [ image dataFormat ];
    pixelFormat = [ image pixelFormat ];
    width = [ image width ];
    height = [ image height ];

    textureFilterState.mipmapping = NP_TEXTURE_FILTER_MIPMAPPING_ACTIVE;
    textureFilterState.minFilter = NP_TEXTURE_FILTER_LINEAR_MIPMAP_LINEAR;
    textureFilterState.magFilter = NP_TEXTURE_FILTER_LINEAR;
    textureFilterState.anisotropy = [[[ NPEngineCore instance ] textureManager ] maxAnisotropy ];

    textureWrapState.wrapS = NP_TEXTURE_WRAPPING_REPEAT;
    textureWrapState.wrapT = NP_TEXTURE_WRAPPING_REPEAT;

    ready = YES;

    [ self uploadToGLUsingImage:image ];
    [ image release ];

	return YES;
}

- (void) reset
{
    glDeleteTextures(1, &textureID);

    np_texture_filter_state_reset(&textureFilterState);
    np_texture_wrap_state_reset(&textureWrapState);

    [ super reset ];
}

- (UInt) textureID
{
    return textureID;
}

- (void) generateGLTextureID
{
    glGenTextures(1, &textureID);
}

- (void) setDataFormat:(NpState)newDataFormat
{
    if ( dataFormat != newDataFormat )
    {
        dataFormat = newDataFormat;
    }
}

- (void) setPixelFormat:(NpState)newPixelFormat
{
    if ( pixelFormat != newPixelFormat )
    {
        pixelFormat = newPixelFormat;
    }
}

- (void) setWidth:(Int)newWidth
{
    if ( width != newWidth )
    {
        width = newWidth;
    }
}

- (void) setHeight:(Int)newHeight
{
    if ( height != newHeight )
    {
        height = newHeight;
    }
}

- (void) setMipMapping:(NpState)newMipMapping
{
    textureFilterState.mipmapping = newMipMapping;
}

- (void) setTextureMinFilter:(NpState)newTextureMinFilter
{
    textureFilterState.minFilter = newTextureMinFilter;

    [ self updateGLTextureState ];
}

- (void) setTextureMagFilter:(NpState)newTextureMagFilter
{
    textureFilterState.magFilter = newTextureMagFilter;

    [ self updateGLTextureState ];
}

- (void) setTextureAnisotropyFilter:(NpState)newTextureAnisotropyFilter
{
    textureFilterState.anisotropy = newTextureAnisotropyFilter;

    [ self updateGLTextureState ];
}

- (void) setTextureWrapS:(NpState)newWrapS
{
    textureWrapState.wrapS = newWrapS;

    [ self updateGLTextureState ];
}

- (void) setTextureWrapT:(NpState)newWrapT
{
    textureWrapState.wrapT = newWrapT;

    [ self updateGLTextureState ];
}

- (void) computeGLDataType:(NpState *)glDataType pixelFormat:(NpState *)glPixelFormat
{
    switch ( dataFormat )
    {
        case ( NP_TEXTURE_DATAFORMAT_BYTE ):
        {
            *glDataType = GL_UNSIGNED_BYTE;
            switch (pixelFormat)
            {
                case ( NP_TEXTURE_PIXELFORMAT_R )    : { *glPixelFormat = GL_LUMINANCE; break; }
                case ( NP_TEXTURE_PIXELFORMAT_RG )   : { *glPixelFormat = GL_LUMINANCE_ALPHA; break; }
                case ( NP_TEXTURE_PIXELFORMAT_RGB )  : { *glPixelFormat = GL_RGB; break; }
                case ( NP_TEXTURE_PIXELFORMAT_RGBA ) : { *glPixelFormat = GL_RGBA; break; }
            }
            break;
        }

        case ( NP_TEXTURE_DATAFORMAT_HALF ):
        {
            *glDataType = GL_HALF_FLOAT_ARB;
            switch (pixelFormat)
            {
                case ( NP_TEXTURE_PIXELFORMAT_R )    : { *glPixelFormat = GL_LUMINANCE; break; }
                case ( NP_TEXTURE_PIXELFORMAT_RG )   : { *glPixelFormat = GL_LUMINANCE_ALPHA; break; }
                case ( NP_TEXTURE_PIXELFORMAT_RGB )  : { *glPixelFormat = GL_RGB; break; }
                case ( NP_TEXTURE_PIXELFORMAT_RGBA ) : { *glPixelFormat = GL_RGBA; break; }
            }
            break;
        }
        case ( NP_TEXTURE_DATAFORMAT_FLOAT ):
        {
            *glDataType = GL_FLOAT;
            switch (pixelFormat)
            {
                case ( NP_TEXTURE_PIXELFORMAT_R )    : { *glPixelFormat = GL_LUMINANCE; break; }
                case ( NP_TEXTURE_PIXELFORMAT_RG )   : { *glPixelFormat = GL_LUMINANCE_ALPHA; break; }
                case ( NP_TEXTURE_PIXELFORMAT_RGB )  : { *glPixelFormat = GL_RGB; break; }
                case ( NP_TEXTURE_PIXELFORMAT_RGBA ) : { *glPixelFormat = GL_RGBA; break; }
            }
            break;
        }
    }
}

- (Int) computeGLInternalTextureFormatUsingDataFormat:(NpState)glDataFormat pixelFormat:(NpState)glPixelFormat
{
    Int textureFormat = -1;

    switch ( glDataFormat )
    {
        case ( NP_TEXTURE_DATAFORMAT_BYTE ):
        {
            switch ( glPixelFormat )
            {
                case ( NP_TEXTURE_PIXELFORMAT_R )    : { textureFormat = GL_LUMINANCE; break; }
                case ( NP_TEXTURE_PIXELFORMAT_RG )   : { textureFormat = GL_LUMINANCE_ALPHA; break; }
                case ( NP_TEXTURE_PIXELFORMAT_RGB )  : { textureFormat = GL_RGB; break; }
                case ( NP_TEXTURE_PIXELFORMAT_RGBA ) : { textureFormat = GL_RGBA; break; }
            }
            break;
        }
        case ( NP_TEXTURE_DATAFORMAT_HALF ):
        {
            switch ( glPixelFormat )
            {
                case ( NP_TEXTURE_PIXELFORMAT_R )    : { textureFormat = GL_LUMINANCE16F_ARB; break; }
                case ( NP_TEXTURE_PIXELFORMAT_RG )   : { textureFormat = GL_LUMINANCE_ALPHA16F_ARB; break; }
                case ( NP_TEXTURE_PIXELFORMAT_RGB )  : { textureFormat = GL_RGB16F_ARB; break; }
                case ( NP_TEXTURE_PIXELFORMAT_RGBA ) : { textureFormat = GL_RGBA16F_ARB; break; }
            }
            break;
        }
        case ( NP_TEXTURE_DATAFORMAT_FLOAT ):
        {
            switch ( glPixelFormat )
            {
                case ( NP_TEXTURE_PIXELFORMAT_R )    : { textureFormat = GL_LUMINANCE32F_ARB; break; }
                case ( NP_TEXTURE_PIXELFORMAT_RG )   : { textureFormat = GL_LUMINANCE_ALPHA32F_ARB; break; }
                case ( NP_TEXTURE_PIXELFORMAT_RGB )  : { textureFormat = GL_RGB32F_ARB; break; }
                case ( NP_TEXTURE_PIXELFORMAT_RGBA ) : { textureFormat = GL_RGBA32F_ARB; break; }
            }
            break;
        }
    }

    return textureFormat;
}

- (void) uploadToGLWithoutImageData
{
    NSData * emptyData = [[ NSData alloc ] init ];
    NPImage * dummyImage = [[ NPImage alloc ] init ];
    [ dummyImage setImageData:emptyData ];

    [ self uploadToGLUsingImage:dummyImage ];
    [ dummyImage release ];
}

- (void) uploadToGLUsingImage:(NPImage *)image
{
    Int glInternalFormat;
    NpState glDataType = NP_NONE;
    NpState glPixelFormat = NP_NONE;

    [ self computeGLDataType:&glDataType pixelFormat:&glPixelFormat];
    glInternalFormat = [ self computeGLInternalTextureFormatUsingDataFormat:(NpState)dataFormat pixelFormat:(NpState)pixelFormat ];

    glBindTexture(GL_TEXTURE_2D, textureID);

    if ( textureFilterState.mipmapping == NP_TEXTURE_FILTER_MIPMAPPING_ACTIVE )
    {
        if ( [[[[ NPEngineCore instance ] renderContextManager ] currentRenderContext ] isExtensionSupported:@"GL_SGIS_generate_mipmap" ] == YES )
        {
            glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP_SGIS, 1);
            glTexImage2D(GL_TEXTURE_2D, 0, glInternalFormat, width, height, 0, glPixelFormat, glDataType, [[image imageData] bytes]);
            glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP_SGIS, 0);
        }
        else
        {
            gluBuild2DMipmaps(GL_TEXTURE_2D, glInternalFormat, width, height, glPixelFormat, glDataType, [[image imageData] bytes]);
        }
    }
    else
    {
        glTexImage2D(GL_TEXTURE_2D, 0, glInternalFormat, width, height, 0, glPixelFormat, glDataType, [[image imageData] bytes]);
    }

    [ self updateGLTextureState ];

    glBindTexture(GL_TEXTURE_2D, 0);
}

- (void)  updateGLTextureFilterState
{
    NpState value = NP_NONE;
    switch ( textureFilterState.magFilter )
    {
        case NP_TEXTURE_FILTER_NEAREST:{value = GL_NEAREST; break;}
        case NP_TEXTURE_FILTER_LINEAR:{value = GL_LINEAR; break;}
    }

    if ( value != NP_NONE )
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, value);

    value = NP_NONE;
    switch ( textureFilterState.minFilter )
    {
        case NP_TEXTURE_FILTER_NEAREST:{value = GL_NEAREST; break;}
        case NP_TEXTURE_FILTER_LINEAR:{value = GL_LINEAR; break;}
        case NP_TEXTURE_FILTER_NEAREST_MIPMAP_NEAREST:{value = GL_NEAREST_MIPMAP_NEAREST; break;}
        case NP_TEXTURE_FILTER_LINEAR_MIPMAP_NEAREST:{value = GL_LINEAR_MIPMAP_NEAREST; break;}
        case NP_TEXTURE_FILTER_NEAREST_MIPMAP_LINEAR:{value = GL_NEAREST_MIPMAP_LINEAR; break;}
        case NP_TEXTURE_FILTER_LINEAR_MIPMAP_LINEAR:{value = GL_LINEAR_MIPMAP_LINEAR; break;}
    }

    if ( value != NP_NONE )
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, value);
}

- (void) updateGLTextureAnisotropy
{
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, textureFilterState.anisotropy);
}

- (void) updateGLTextureWrapState
{
    NpState wrapS = NP_NONE;
    switch (textureWrapState.wrapS)
    {
        case NP_TEXTURE_WRAPPING_CLAMP:{wrapS = GL_CLAMP; break;}
        case NP_TEXTURE_WRAPPING_CLAMP_TO_EDGE:{wrapS = GL_CLAMP_TO_EDGE; break;}
        case NP_TEXTURE_WRAPPING_CLAMP_TO_BORDER:{wrapS = GL_CLAMP_TO_BORDER; break;}
        case NP_TEXTURE_WRAPPING_REPEAT:{wrapS = GL_REPEAT; break;}
    }

    NpState wrapT = NP_NONE;
    switch (textureWrapState.wrapS)
    {
        case NP_TEXTURE_WRAPPING_CLAMP:{wrapT = GL_CLAMP; break;}
        case NP_TEXTURE_WRAPPING_CLAMP_TO_EDGE:{wrapT = GL_CLAMP_TO_EDGE; break;}
        case NP_TEXTURE_WRAPPING_CLAMP_TO_BORDER:{wrapT = GL_CLAMP_TO_BORDER; break;}
        case NP_TEXTURE_WRAPPING_REPEAT:{wrapT = GL_REPEAT; break;}
    }

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, wrapS);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, wrapT);
}

- (void) updateGLTextureState
{
    [ self updateGLTextureFilterState ];
    [ self updateGLTextureAnisotropy ];
    [ self updateGLTextureWrapState ];
}

@end
