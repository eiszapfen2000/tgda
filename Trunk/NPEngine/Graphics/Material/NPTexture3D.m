#import "NPTexture3D.h"
#import "NP.h"

@implementation NPTexture3D

- (id) init
{
    return [ self initWithName:@"NPTexture3D" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    textureID = [[[ NP Graphics ] textureManager ] generateGLTextureID ];
    width = height = depth = -1;
    dataFormat  = NP_NONE;
    pixelFormat = NP_NONE;

    //equals opengl default states
    np_texture3d_filter_state_reset(&textureFilterState);
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

    width = height = depth = -1;
    dataFormat  = NP_NONE;
    pixelFormat = NP_NONE;   

    np_texture_filter_state_reset(&textureFilterState);
    np_texture_wrap_state_reset(&textureWrapState);
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

- (Int) depth
{
    return depth;
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

- (void) setDepth:(Int)newDepth
{
    depth = newDepth;
}

- (void) setTextureFilter:(NpState)newTextureFilter
{
    switch ( newTextureFilter )
    {
        case NP_GRAPHICS_TEXTURE_FILTER_LINEAR:
        {
            textureFilterState.minFilter  = NP_GRAPHICS_TEXTURE_FILTER_LINEAR;
            textureFilterState.magFilter  = NP_GRAPHICS_TEXTURE_FILTER_LINEAR;
            textureFilterState.mipmapping = NP_GRAPHICS_TEXTURE_FILTER_MIPMAPPING_INACTIVE;

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

- (void) setTextureWrap:(NpState)newWrap
{
    textureWrapState.wrapR = newWrap;
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

- (void) uploadToGLWithoutData
{
    [ self uploadToGLWithData:[NSData data]];
}

#warning FIXME implement mipmapping

- (void) uploadToGLWithData:(NSData *)data
{
    GLint glinternalformat;
    GLenum gldataformat;
    GLenum glpixelformat;

    gldataformat  = [[[ NP Graphics ] textureManager ] computeGLDataFormat :dataFormat  ];
    glpixelformat = [[[ NP Graphics ] textureManager ] computeGLPixelFormat:pixelFormat ];
    glinternalformat = [[[ NP Graphics ] textureManager ] computeGLInternalTextureFormatUsingDataFormat:dataFormat pixelFormat:pixelFormat ];

    [[[ NP Graphics ] textureManager ] setTexture3DMode ];

    glBindTexture(GL_TEXTURE_3D, textureID);
    glTexImage3D(GL_TEXTURE_3D, 0, glinternalformat, width, height, depth, 0, glpixelformat, gldataformat, [data bytes]);

    [ self updateGLTextureState ];

    glBindTexture(GL_TEXTURE_3D, 0);
}

- (void) updateGLTextureFilterState
{
    GLenum value = GL_NONE;

    switch ( textureFilterState.magFilter )
    {
        case NP_GRAPHICS_TEXTURE_FILTER_NEAREST:{ value = GL_NEAREST; break; }
        case NP_GRAPHICS_TEXTURE_FILTER_LINEAR :{ value = GL_LINEAR;  break; }
        default: { NPLOG_ERROR(@"%@ unknown mag filter %d", name, textureFilterState.magFilter); break; }
    }

    glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MAG_FILTER, value);

    value = GL_NONE;
    switch ( textureFilterState.minFilter )
    {
        case NP_GRAPHICS_TEXTURE_FILTER_NEAREST:{ value = GL_NEAREST; break; }
        case NP_GRAPHICS_TEXTURE_FILTER_LINEAR :{ value = GL_LINEAR;  break; }
        default: { NPLOG_ERROR(@"%@ unknown min filter %d", name, textureFilterState.minFilter); break; }
    }

    glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MIN_FILTER, value);
}

- (void) updateGLTextureWrapState
{
    GLenum wrapS = [[[ NP Graphics ] textureManager ] computeGLWrap:textureWrapState.wrapS ];
    GLenum wrapT = [[[ NP Graphics ] textureManager ] computeGLWrap:textureWrapState.wrapT ];
    GLenum wrapR = [[[ NP Graphics ] textureManager ] computeGLWrap:textureWrapState.wrapR ];

    glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_S, wrapS);
    glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_T, wrapT);
    glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_R, wrapR);
}

- (void) updateGLTextureState
{
    [[[ NP Graphics ] textureManager ] setTexture3DMode ];

    glBindTexture(GL_TEXTURE_3D, textureID);

    [ self updateGLTextureFilterState ];
    [ self updateGLTextureWrapState   ];

    glBindTexture(GL_TEXTURE_3D, 0);
}

- (void) activateAtVolumeMapIndex:(Int32)index
{
    [[[ NP Graphics ] textureBindingState ] setTexture:self forKey:NP_GRAPHICS_MATERIAL_VOLUMEMAP_SEMANTIC(index) ];
}

@end
