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

- (void) setTextureFilter:(NpState)newTextureFilter
{
    switch ( newTextureFilter )
    {
        case NP_GRAPHICS_TEXTURE_FILTER_NEAREST:
        {
            textureFilterState.minFilter = NP_GRAPHICS_TEXTURE_FILTER_NEAREST;
            textureFilterState.magFilter = NP_GRAPHICS_TEXTURE_FILTER_NEAREST;
            textureFilterState.mipmapping = NP_GRAPHICS_TEXTURE_FILTER_MIPMAPPING_INACTIVE;

            break;
        }

        case NP_GRAPHICS_TEXTURE_FILTER_LINEAR:
        {
            textureFilterState.minFilter = NP_GRAPHICS_TEXTURE_FILTER_LINEAR;
            textureFilterState.magFilter = NP_GRAPHICS_TEXTURE_FILTER_LINEAR;
            textureFilterState.mipmapping = NP_GRAPHICS_TEXTURE_FILTER_MIPMAPPING_INACTIVE;

            break;
        }

        case NP_GRAPHICS_TEXTURE_FILTER_LINEAR_MIPMAPPING:
        {
            textureFilterState.minFilter = NP_GRAPHICS_TEXTURE_FILTER_LINEAR_MIPMAP_NEAREST;
            textureFilterState.magFilter = NP_GRAPHICS_TEXTURE_FILTER_NEAREST;
            textureFilterState.mipmapping = NP_GRAPHICS_TEXTURE_FILTER_MIPMAPPING_ACTIVE;

            break;
        }

        case NP_GRAPHICS_TEXTURE_FILTER_TRILINEAR:
        {
            textureFilterState.minFilter = NP_GRAPHICS_TEXTURE_FILTER_LINEAR_MIPMAP_LINEAR;
            textureFilterState.magFilter = NP_GRAPHICS_TEXTURE_FILTER_LINEAR;
            textureFilterState.mipmapping = NP_GRAPHICS_TEXTURE_FILTER_MIPMAPPING_ACTIVE;

            break;
        }

        default:
        {
            NPLOG_WARNING(@"%@: Unknown texture filter %d", name, newTextureFilter);
        }
    }

    [ self updateGLTextureState ];
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

- (void) setTextureWrap:(NpState)newWrap
{
    textureWrapState.wrapS = newWrap;
    textureWrapState.wrapT = newWrap;

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
    textureFilterState.anisotropy = [[[ NP Graphics ] textureManager ] anisotropy ];

    textureWrapState.wrapS = NP_GRAPHICS_TEXTURE_WRAPPING_REPEAT;
    textureWrapState.wrapT = NP_GRAPHICS_TEXTURE_WRAPPING_REPEAT;

    ready = YES;

    [ self uploadToGLUsingImage:image ];
    [ image release ];

	return YES;
}

- (void) uploadToGLWithoutData
{
    NSData * emptyData = [ NSData data ];
    [ self uploadToGLWithData:emptyData ];
}

- (void) uploadToGLUsingImage:(NPImage *)image
{
    [ self uploadToGLWithData:[image imageData]];
}

- (void) uploadToGLWithData:(NSData *)data
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
        if ( [[[ NP Graphics ] textureManager ] hardwareMipMapGenerationSupport ] == YES )
        {
            glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP_SGIS, 1);
            glTexImage2D(GL_TEXTURE_2D, 0, glinternalformat, width, height, 0, glpixelformat, gldataformat, [data bytes]);
            glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP_SGIS, 0);
        }
        else
        {
            gluBuild2DMipmaps(GL_TEXTURE_2D, glinternalformat, width, height, glpixelformat, gldataformat, [data bytes]);
        }
    }
    else
    {
        glTexImage2D(GL_TEXTURE_2D, 0, glinternalformat, width, height, 0, glpixelformat, gldataformat, [data bytes]);
    }

    [ self updateGLTextureState ];

    glBindTexture(GL_TEXTURE_2D, 0);
}

- (void) uploadImage:(NPImage *)image toMipmapLevel:(Int32)level
{
    [ self uploadData:[image imageData] toMipmapLevel:level ];
}

- (void) uploadData:(NSData *)data toMipmapLevel:(Int32)level
{
	#define NP_MAX(_a,_b) ((_a > _b )? _a:_b)

    Int32 numberOfLevels = 1 + floor(logb(NP_MAX(width, height)));

    if ( level < 0 || level > numberOfLevels )
    {
        return;
    }

    GLint glinternalformat;
    GLenum gldataformat;
    GLenum glpixelformat;

    gldataformat  = [[[ NP Graphics ] textureManager ] computeGLDataFormat :dataFormat  ];
    glpixelformat = [[[ NP Graphics ] textureManager ] computeGLPixelFormat:pixelFormat ];
    glinternalformat = [[[ NP Graphics ] textureManager ] computeGLInternalTextureFormatUsingDataFormat:dataFormat pixelFormat:pixelFormat ];

    Int32 mipLevelWidth = width;
    Int32 mipLevelHeight = height;
    Int32 nextMipLevelWidth;
    Int32 nextMipLevelHeight;

    for ( Int32 i = 0; i < level; i++ )
    {
        nextMipLevelWidth = NP_MAX(1, mipLevelWidth >> 1);
        nextMipLevelHeight = NP_MAX(1, mipLevelHeight >> 1);

        mipLevelWidth = nextMipLevelWidth;
        mipLevelHeight = nextMipLevelHeight;
    }

    glTexSubImage2D(GL_TEXTURE_2D, level, 0, 0, mipLevelWidth, mipLevelHeight, glpixelformat, glpixelformat, [data bytes]);
}

- (void)  updateGLTextureFilterState
{
    GLenum value = GL_NONE;

    switch ( textureFilterState.magFilter )
    {
        case NP_GRAPHICS_TEXTURE_FILTER_NEAREST:{ value = GL_NEAREST; break; }
        case NP_GRAPHICS_TEXTURE_FILTER_LINEAR :{ value = GL_LINEAR;  break; }
        default: { NPLOG_ERROR(@"%@ unknown mag filter %d", name, textureFilterState.magFilter); break; }
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
        default: { NPLOG_ERROR(@"%@ unknown min filter %d", name, textureFilterState.minFilter); break; }
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
    //GLenum wrapR = [[[ NP Graphics ] textureManager ] computeGLWrap:textureWrapState.wrapR ];

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, wrapS);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, wrapT);
    //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_R, wrapR);
}

- (void) updateGLTextureState
{
    [[[ NP Graphics ] textureManager ] setTexture2DMode ];

    glBindTexture(GL_TEXTURE_2D, textureID);

    [ self updateGLTextureFilterState ];
    [ self updateGLTextureAnisotropy ];
    [ self updateGLTextureWrapState ];

    glBindTexture(GL_TEXTURE_2D, 0);
}

- (void) activateAtColorMapIndex:(Int32)index
{
    [[[[ NP Graphics ] textureBindingStateManager ] currentTextureBindingState ] setTexture:self forKey:NP_GRAPHICS_MATERIAL_COLORMAP_SEMANTIC(index) ];
}

- (void) activateAtTexelUnit:(Int32)texelUnit
{
    [[[[ NP Graphics ] textureBindingStateManager ] currentTextureBindingState ] setTexture:self forTexelUnit:texelUnit ];
}

- (void) deactivate
{
    [[[[ NP Graphics ] textureBindingStateManager ] currentTextureBindingState ] deactivateTexelUnitForTexture:self ];
}

@end
