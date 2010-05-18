#import "Graphics/npgl.h"
#import "NPTextureManager.h"
#import "NP.h"

@implementation NPTextureManager

- (id) init
{
    return [ self initWithParent:nil ];
}

- (id) initWithParent:(id <NPPObject> )newParent
{
    return [ self initWithName:@"NPTextureManager" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    textures = [[ NSMutableDictionary alloc ] init ];
    maxAnisotropy = anisotropy = 1;
    nonPOTSupport = NO;
    srgbTextureSupport = NO;
    textureMode = NP_NONE;

    return self;
}

- (void) dealloc
{
    [ textures removeAllObjects ];
    [ textures release ];

    [ super dealloc ];
}

- (void) setup
{
    NPOpenGLRenderContext * context = [[[ NP Graphics ] renderContextManager ] currentRenderContext ];

    if ( [ context isExtensionSupported:@"GL_EXT_texture_filter_anisotropic" ] == YES )
    {
        glGetIntegerv(GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT,&maxAnisotropy);
        NPLOG(@"%@: maximum anisotropy %d", name, maxAnisotropy);
    }

    if ( [ context isExtensionSupported:@"GL_ARB_texture_non_power_of_two" ] == YES )
    {
        nonPOTSupport = YES;
        NPLOG(@"%@: Non power of two textures supported", name);
    }

    if ( [ context isExtensionSupported:@"GL_SGIS_generate_mipmap" ] == YES )
    {
        hardwareMipMapGenerationSupport = YES;
        NPLOG(@"%@: Hardware mipmap generation supported", name);
    }

    if ( [ context isExtensionSupported:@"GL_EXT_texture_sRGB" ] == YES )
    {
        srgbTextureSupport = YES;
        NPLOG(@"%@: sRGB sampler supported", name);
    }

    [ self setTexture2DMode ];
}

- (NpState) anisotropy
{
    return anisotropy;
}

- (NpState) maxAnisotropy
{
    return maxAnisotropy;
}

- (BOOL) nonPOTSupport
{
    return nonPOTSupport;
}

- (BOOL) hardwareMipMapGenerationSupport
{
    return hardwareMipMapGenerationSupport;
}

- (NpState) textureMode
{
    return textureMode;
}

- (void) setAnisotropy:(NpState)newAnisotropy
{
    if ( newAnisotropy <= maxAnisotropy )
    {
        anisotropy = newAnisotropy;
    }
}

- (void) setTextureMode:(NpState)newTextureMode
{
    if ( textureMode != newTextureMode )
    {
        switch ( newTextureMode )
        {
            case NP_GRAPHICS_TEXTURE_MODE_2D:{ textureMode = newTextureMode; glEnable(GL_TEXTURE_2D); break; }
            case NP_GRAPHICS_TEXTURE_MODE_3D:{ textureMode = newTextureMode; glEnable(GL_TEXTURE_3D); break; }
            default: { NPLOG_ERROR(([NSString stringWithFormat:@"%@: unknow texture mode %d", name, newTextureMode])); break; }
        }
    }
}

- (void) setTexture2DMode
{
    textureMode = NP_GRAPHICS_TEXTURE_MODE_2D;
    glEnable(GL_TEXTURE_2D);
}

- (void) setTexture3DMode
{
    textureMode = NP_GRAPHICS_TEXTURE_MODE_3D;
    glEnable(GL_TEXTURE_3D);
}

- (UInt) generateGLTextureID
{
    UInt textureID = NP_NONE;
    glGenTextures(1, &textureID);

    return textureID;
}

- (GLenum) computeGLWrap:(NpState)wrap
{
    GLenum glwrap = GL_NONE;
    switch ( wrap )
    {
        case NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP :{ glwrap = GL_CLAMP;  break; }
        case NP_GRAPHICS_TEXTURE_WRAPPING_REPEAT:{ glwrap = GL_REPEAT; break; }
        case NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE  :{ glwrap = GL_CLAMP_TO_EDGE;   break; }
        case NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_BORDER:{ glwrap = GL_CLAMP_TO_BORDER; break; }
        default: { NPLOG_ERROR(@"%@ unknown wrap %d",name,wrap); break; }
    }

    return glwrap;
}

- (GLenum) computeGLDataFormat:(NpState)dataFormat
{
    GLenum gldataformat = 0;

    switch ( dataFormat )
    {
        case ( NP_GRAPHICS_TEXTURE_DATAFORMAT_BYTE ) :{ gldataformat = GL_UNSIGNED_BYTE;  break; }
        case ( NP_GRAPHICS_TEXTURE_DATAFORMAT_HALF ) :{ gldataformat = GL_HALF_FLOAT_ARB; break; }
        case ( NP_GRAPHICS_TEXTURE_DATAFORMAT_FLOAT ):{ gldataformat = GL_FLOAT;          break; }
        default:{ NPLOG_ERROR(@"%@: Unknown data format %d",name,dataFormat); break; }
    }

    return gldataformat;
}

- (GLenum) computeGLPixelFormat:(NpState)pixelFormat
{
    GLenum glpixelformat = 0;

    switch ( pixelFormat )
    {
        case ( NP_GRAPHICS_TEXTURE_PIXELFORMAT_R )  :
        case ( NP_GRAPHICS_TEXTURE_PIXELFORMAT_sR ) :
        {
            glpixelformat = GL_LUMINANCE;
            break;
        }

        case ( NP_GRAPHICS_TEXTURE_PIXELFORMAT_RG )  :
        case ( NP_GRAPHICS_TEXTURE_PIXELFORMAT_sRG ) :
        {
            glpixelformat = GL_LUMINANCE_ALPHA;
            break;
        }

        case ( NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGB )  :
        case ( NP_GRAPHICS_TEXTURE_PIXELFORMAT_sRGB ) :
        {
            glpixelformat = GL_RGB;
            break;
        }

        case ( NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA ) :
        case ( NP_GRAPHICS_TEXTURE_PIXELFORMAT_sRGB_LINEAR_ALPHA ) :
        {
            glpixelformat = GL_RGBA;
            break;
        }

        default:{ NPLOG_ERROR(@"%@: Unknown pixel format %d", name, pixelFormat); break; }
    }

    return glpixelformat;
}

- (GLint) computeGLInternalTextureFormatUsingDataFormat:(NpState)dataFormat pixelFormat:(NpState)pixelFormat
{
    GLint glinternalformat = 0;

    switch ( dataFormat )
    {
        case ( NP_GRAPHICS_TEXTURE_DATAFORMAT_BYTE ):
        {
            if ( srgbTextureSupport == NO )
            {
                switch ( pixelFormat )
                {
                    case ( NP_GRAPHICS_TEXTURE_PIXELFORMAT_R )  :
                    case ( NP_GRAPHICS_TEXTURE_PIXELFORMAT_sR ) :
                    {
                        glinternalformat = GL_LUMINANCE;
                        break;
                    }

                    case ( NP_GRAPHICS_TEXTURE_PIXELFORMAT_RG )  :
                    case ( NP_GRAPHICS_TEXTURE_PIXELFORMAT_sRG ) :
                    {
                        glinternalformat = GL_LUMINANCE_ALPHA;
                        break;
                    }

                    case ( NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGB )  :
                    case ( NP_GRAPHICS_TEXTURE_PIXELFORMAT_sRGB ) :
                    {
                        glinternalformat = GL_RGB;
                        break;
                    }

                    case ( NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA ) :
                    case ( NP_GRAPHICS_TEXTURE_PIXELFORMAT_sRGB_LINEAR_ALPHA ) :
                    {
                        glinternalformat = GL_RGBA;
                        break;
                    }
                }
            }
            else
            {
                switch ( pixelFormat )
                {
                    case ( NP_GRAPHICS_TEXTURE_PIXELFORMAT_R )    : { glinternalformat = GL_LUMINANCE;       break; }
                    case ( NP_GRAPHICS_TEXTURE_PIXELFORMAT_RG )   : { glinternalformat = GL_LUMINANCE_ALPHA; break; }
                    case ( NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGB )  : { glinternalformat = GL_RGB;             break; }
                    case ( NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA ) : { glinternalformat = GL_RGBA;            break; }

                    case ( NP_GRAPHICS_TEXTURE_PIXELFORMAT_sR )    : { glinternalformat = GL_SLUMINANCE;       break; }
                    case ( NP_GRAPHICS_TEXTURE_PIXELFORMAT_sRG )   : { glinternalformat = GL_SLUMINANCE_ALPHA; break; }
                    case ( NP_GRAPHICS_TEXTURE_PIXELFORMAT_sRGB )  : { glinternalformat = GL_SRGB;             break; }
                    case ( NP_GRAPHICS_TEXTURE_PIXELFORMAT_sRGB_LINEAR_ALPHA ) : { glinternalformat = GL_SRGB_ALPHA; break; }
                }
            }

            break;
        }

        case ( NP_GRAPHICS_TEXTURE_DATAFORMAT_HALF ):
        {
            switch ( pixelFormat )
            {
                case ( NP_GRAPHICS_TEXTURE_PIXELFORMAT_R )    : { glinternalformat = GL_LUMINANCE16F_ARB;       break; }
                case ( NP_GRAPHICS_TEXTURE_PIXELFORMAT_RG )   : { glinternalformat = GL_LUMINANCE_ALPHA16F_ARB; break; }
                case ( NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGB )  : { glinternalformat = GL_RGB16F_ARB;             break; }
                case ( NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA ) : { glinternalformat = GL_RGBA16F_ARB;            break; }
            }

            break;
        }

        case ( NP_GRAPHICS_TEXTURE_DATAFORMAT_FLOAT ):
        {
            switch ( pixelFormat )
            {
                case ( NP_GRAPHICS_TEXTURE_PIXELFORMAT_R )    : { glinternalformat = GL_LUMINANCE32F_ARB;       break; }
                case ( NP_GRAPHICS_TEXTURE_PIXELFORMAT_RG )   : { glinternalformat = GL_LUMINANCE_ALPHA32F_ARB; break; }
                case ( NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGB )  : { glinternalformat = GL_RGB32F_ARB;             break; }
                case ( NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA ) : { glinternalformat = GL_RGBA32F_ARB;            break; }
            }

            break;
        }
    }

    return glinternalformat;
}

- (id) loadTextureFromPath:(NSString *)path
{
    NSString * absolutePath = [[[ NP Core ] pathManager ] getAbsoluteFilePath:path ];

    return [ self loadTextureFromAbsolutePath:absolutePath ];
}

- (id) loadTextureFromAbsolutePath:(NSString *)path
{
    if ( [ path isEqual:@"" ] == NO )
    {
        NPTexture * texture = [ textures objectForKey:path ];

        if ( texture == nil )
        {
            NPLOG(@"%@: loading %@", name, path);

            NPFile * file = [[ NPFile alloc ] initWithName:path parent:self fileName:path ];
            texture = [ self loadTextureUsingFileHandle:file ];
            [ file release ];
        }

        return texture;
    }

    return nil;    
}

- (id) loadTextureUsingFileHandle:(NPFile *)file
{
    NPTexture * texture = [[ NPTexture alloc ] initWithName:@"" parent:self ];

    if ( [ texture loadFromFile:file ] == YES )
    {
        [ textures setObject:texture forKey:[file fileName] ];
        [ texture release ];

        return texture;
    }
    else
    {
        [ texture release ];

        return nil;
    }    
}

- (id) textureWithName:(NSString *)textureName
                 width:(Int)width 
                height:(Int)height
            dataFormat:(NpState)dataFormat
           pixelFormat:(NpState)pixelFormat

{
    return [ self textureWithName:textureName
                            width:width
                           height:height
                       dataFormat:dataFormat
                      pixelFormat:pixelFormat
                       mipMapping:NP_GRAPHICS_TEXTURE_FILTER_MIPMAPPING_INACTIVE ];
}

- (id) textureWithName:(NSString *)textureName
                 width:(Int)width 
                height:(Int)height
            dataFormat:(NpState)dataFormat
           pixelFormat:(NpState)pixelFormat
            mipMapping:(NpState)mipMapping
{
    NPTexture * texture = [[ NPTexture alloc ] initWithName:textureName parent:self ];
    [ texture setWidth:width ];
    [ texture setHeight:height ];
    [ texture setDataFormat:dataFormat ];
    [ texture setPixelFormat:pixelFormat ];
    [ texture setMipMapping:mipMapping ];

    [ textures setObject:texture forKey:textureName ];

    return [ texture autorelease ];
}

- (id) texture3DWithName:(NSString *)textureName
                   width:(Int)width 
                  height:(Int)height
                   depth:(Int)depth
              dataFormat:(NpState)dataFormat
             pixelFormat:(NpState)pixelFormat
{
    NPTexture3D * texture = [[ NPTexture3D alloc ] initWithName:textureName parent:self ];
    [ texture setWidth:width ];
    [ texture setHeight:height ];
    [ texture setDepth:depth ];
    [ texture setDataFormat:dataFormat ];
    [ texture setPixelFormat:pixelFormat ];

    [ textures setObject:texture forKey:textureName ];

    return [ texture autorelease ];
}

- (id) texture3DWithName:(NSString *)textureName
                   width:(Int)width 
                  height:(Int)height
                   depth:(Int)depth
              dataFormat:(NpState)dataFormat
             pixelFormat:(NpState)pixelFormat
              mipmapping:(NpState)mipMapping
{
    return nil;
}

@end
