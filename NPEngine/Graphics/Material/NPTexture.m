#import "NPTexture.h"
#import "NP.h"

@implementation NPTexture

- (id) init
{
    return [ self initWithName:@"NPTexture" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    textureID = [[[ NP Graphics ] textureManager ] generateGLTextureID ];
    width = height = -1;
    dataFormat  = NP_NONE;
    pixelFormat = NP_NONE;

    //equals opengl default states
    np_texture_filter_state_reset(&textureFilterState);
    np_texture_wrap_state_reset(&textureWrapState);

    return self;
}

- (void) dealloc
{
    [ self clear ];   

    [ super dealloc ];
}

- (void) clear
{
    if ( textureID > 0 )
    {
        glDeleteTextures(1, &textureID);
    }
}

- (void) reset
{
    if ( textureID > 0 )
    {
        glDeleteTextures(1, &textureID);
        textureID = [[[ NP Graphics ] textureManager ] generateGLTextureID ];
    }

    width = height = -1;
    dataFormat  = NP_NONE;
    pixelFormat = NP_NONE;   

    np_texture_filter_state_reset(&textureFilterState);
    np_texture_wrap_state_reset(&textureWrapState);

    [ super reset ];
}

- (UInt) textureID
{
    return textureID;
}

- (NpState) dataFormat
{
    return dataFormat;
}

- (NpState) pixelFormat
{
    return pixelFormat;
}

- (Int) width
{
    return width;
}

- (Int) height
{
    return height;
}

- (void) setDataFormat:(NpState)newDataFormat
{
    dataFormat = newDataFormat;
}

- (void) setPixelFormat:(NpState)newPixelFormat
{
    pixelFormat = newPixelFormat;
}

- (void) setWidth:(Int)newWidth
{
    width = newWidth;
}

- (void) setHeight:(Int)newHeight
{
    height = newHeight;
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

- (BOOL) loadFromFile:(NPFile *)file
{
    [ self reset ];

    [ self setFileName:[ file fileName ]];
    [ self setName:[ file fileName ]];

    NPImage * image = [[ NPImage alloc ] init ];
    if ( [ image loadFromPath:[file fileName]] == NO )
    {
        return NO;
    }

    dataFormat  = [ image dataFormat  ];
    pixelFormat = [ image pixelFormat ];
    width  = [ image width  ];
    height = [ image height ];

    textureFilterState.mipmapping = NP_GRAPHICS_TEXTURE_FILTER_MIPMAPPING_ACTIVE;
    textureFilterState.minFilter  = NP_GRAPHICS_TEXTURE_FILTER_LINEAR_MIPMAP_LINEAR;
    textureFilterState.magFilter  = NP_GRAPHICS_TEXTURE_FILTER_LINEAR;
    textureFilterState.anisotropy = [[[ NP Graphics ] textureManager ] maxAnisotropy ];

    textureWrapState.wrapS = NP_GRAPHICS_TEXTURE_WRAPPING_REPEAT;
    textureWrapState.wrapT = NP_GRAPHICS_TEXTURE_WRAPPING_REPEAT;

    ready = YES;

    [ self uploadToGLUsingImage:image ];
    [ image release ];

	return YES;
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
    GLint glinternalformat;
    GLenum gldataformat;
    GLenum glpixelformat;

    gldataformat  = [[[ NP Graphics ] textureManager ] computeGLDataFormat :dataFormat  ];
    glpixelformat = [[[ NP Graphics ] textureManager ] computeGLPixelFormat:pixelFormat ];
    glinternalformat = [[[ NP Graphics ] textureManager ] computeGLInternalTextureFormatUsingDataFormat:dataFormat pixelFormat:pixelFormat ];

    [[[ NP Graphics ] textureManager ] setTexture2DMode ];

    glBindTexture(GL_TEXTURE_2D, textureID);

    if ( textureFilterState.mipmapping == NP_GRAPHICS_TEXTURE_FILTER_MIPMAPPING_ACTIVE )
    {
        if ( [[[[ NP Graphics ] renderContextManager ] currentRenderContext ] isExtensionSupported:@"GL_SGIS_generate_mipmap" ] == YES )
        {
            glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP_SGIS, 1);
            glTexImage2D(GL_TEXTURE_2D, 0, glinternalformat, width, height, 0, glpixelformat, gldataformat, [[image imageData] bytes]);
            glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP_SGIS, 0);
        }
        else
        {
            gluBuild2DMipmaps(GL_TEXTURE_2D, glinternalformat, width, height, glpixelformat, gldataformat, [[image imageData] bytes]);
        }
    }
    else
    {
        glTexImage2D(GL_TEXTURE_2D, 0, glinternalformat, width, height, 0, glpixelformat, gldataformat, [[image imageData] bytes]);
    }

    [ self updateGLTextureState ];

    glBindTexture(GL_TEXTURE_2D, 0);
}

- (void)  updateGLTextureFilterState
{
    GLenum value = GL_NONE;

    switch ( textureFilterState.magFilter )
    {
        case NP_GRAPHICS_TEXTURE_FILTER_NEAREST:{ value = GL_NEAREST; break; }
        case NP_GRAPHICS_TEXTURE_FILTER_LINEAR :{ value = GL_LINEAR;  break; }
        default: { NPLOG_ERROR(@"%@ unknown mag filter %d",self,textureFilterState.magFilter); break; }
    }

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, value);

    value = GL_NONE;
    switch ( textureFilterState.minFilter )
    {
        case NP_GRAPHICS_TEXTURE_FILTER_NEAREST:{ value = GL_NEAREST; break; }
        case NP_GRAPHICS_TEXTURE_FILTER_LINEAR :{ value = GL_LINEAR;  break; }
        case NP_GRAPHICS_TEXTURE_FILTER_NEAREST_MIPMAP_NEAREST:{ value = GL_NEAREST_MIPMAP_NEAREST; break; }
        case NP_GRAPHICS_TEXTURE_FILTER_LINEAR_MIPMAP_NEAREST :{ value = GL_LINEAR_MIPMAP_NEAREST;  break; }
        case NP_GRAPHICS_TEXTURE_FILTER_NEAREST_MIPMAP_LINEAR :{ value = GL_NEAREST_MIPMAP_LINEAR;  break; }
        case NP_GRAPHICS_TEXTURE_FILTER_LINEAR_MIPMAP_LINEAR  :{ value = GL_LINEAR_MIPMAP_LINEAR;   break; }
        default: { NPLOG_ERROR(@"%@ unknown min filter %d",self,textureFilterState.minFilter); break; }
    }

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, value);
}

- (void) updateGLTextureAnisotropy
{
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, textureFilterState.anisotropy);
}

- (void) updateGLTextureWrapState
{
    GLenum wrapS = [[[ NP Graphics ] textureManager ] computeGLWrap:textureWrapState.wrapS ];
    GLenum wrapT = [[[ NP Graphics ] textureManager ] computeGLWrap:textureWrapState.wrapT ];
    GLenum wrapR = [[[ NP Graphics ] textureManager ] computeGLWrap:textureWrapState.wrapR ];

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, wrapS);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, wrapT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_R, wrapR);
}

- (void) updateGLTextureState
{
    [[[ NP Graphics ] textureManager ] setTexture2DMode ];

    glBindTexture(GL_TEXTURE_2D,textureID);

    [ self updateGLTextureFilterState ];
    [ self updateGLTextureAnisotropy ];
    [ self updateGLTextureWrapState ];

    glBindTexture(GL_TEXTURE_2D,0);
}

@end
