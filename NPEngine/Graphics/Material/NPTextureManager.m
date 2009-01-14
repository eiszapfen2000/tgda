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
    maxAnisotropy = 1;

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
    if ( [[[[ NP Graphics ] renderContextManager ] currentRenderContext ] isExtensionSupported:@"GL_EXT_texture_filter_anisotropic" ] == YES )
    {
        glGetIntegerv(GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT,&maxAnisotropy);
    }

    glEnable(GL_TEXTURE_2D);
}

- (Int) maxAnisotropy
{
    return maxAnisotropy;
}

- (GLenum) computeGLDataFormat:(NpState)dataFormat
{
    GLenum gldataformat = 0;

    switch ( dataFormat )
    {
        case ( NP_GRAPHICS_TEXTURE_DATAFORMAT_BYTE ) :{ gldataformat = GL_UNSIGNED_BYTE;  break; }
        case ( NP_GRAPHICS_TEXTURE_DATAFORMAT_HALF ) :{ gldataformat = GL_HALF_FLOAT_ARB; break; }
        case ( NP_GRAPHICS_TEXTURE_DATAFORMAT_FLOAT ):{ gldataformat = GL_FLOAT;          break; }
    }

    return gldataformat;
}

- (GLenum) computeGLPixelFormat:(NpState)pixelFormat
{
    GLenum glpixelformat = 0;

    switch ( pixelFormat )
    {
        case ( NP_GRAPHICS_TEXTURE_PIXELFORMAT_R )    : { glpixelformat = GL_LUMINANCE;       break; }
        case ( NP_GRAPHICS_TEXTURE_PIXELFORMAT_RG )   : { glpixelformat = GL_LUMINANCE_ALPHA; break; }
        case ( NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGB )  : { glpixelformat = GL_RGB;             break; }
        case ( NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA ) : { glpixelformat = GL_RGBA;            break; }
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
            switch ( pixelFormat )
            {
                case ( NP_GRAPHICS_TEXTURE_PIXELFORMAT_R )    : { glinternalformat = GL_LUMINANCE;       break; }
                case ( NP_GRAPHICS_TEXTURE_PIXELFORMAT_RG )   : { glinternalformat = GL_LUMINANCE_ALPHA; break; }
                case ( NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGB )  : { glinternalformat = GL_RGB;             break; }
                case ( NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA ) : { glinternalformat = GL_RGBA;            break; }
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
    NPLOG(([NSString stringWithFormat:@"%@: loading %@", name, path]));

    if ( [ path isEqual:@"" ] == NO )
    {
        NPTexture * texture = [ textures objectForKey:path ];

        if ( texture == nil )
        {
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

- (id) createTextureWithName:(NSString *)textureName
                       width:(Int)width 
                      height:(Int)height
                  dataFormat:(NpState)dataFormat
                 pixelFormat:(NpState)pixelFormat

{
    return [ self createTextureWithName:textureName
                                  width:width
                                 height:height
                             dataFormat:dataFormat
                            pixelFormat:pixelFormat
                             mipMapping:NP_GRAPHICS_TEXTURE_FILTER_MIPMAPPING_INACTIVE ];
}

- (id) createTextureWithName:(NSString *)textureName
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

@end
