#import <Foundation/NSData.h>
#import "Graphics/Image/NPImage.h"
#import "NPTexture2D.h"

void reset_texture2d_filterstate(NpTexture2DFilterState * filterState)
{
    filterState->mipmaps = NO;
    filterState->textureFilter = NpTexture2DFilterLinear;
    filterState->anisotropy = 1;
}

void reset_texture2d_wrapstate(NpTexture2DWrapState * wrapState)
{
    wrapState->wrapS = NpTextureWrapToEdge;
    wrapState->wrapT = NpTextureWrapToEdge;
}

@implementation NPTexture2D

- (id) init
{
    return [ self initWithName:@"Texture2D" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    return [ super initWithName:newName parent:newParent ];
}

- (void) dealloc
{
    [ super dealloc ];
}

- (void) clear
{
    if (glID > 0 )
    {
        glDeleteTextures(1, &glID);
        glID = 0;
    }
}

- (void) reset
{
    [ self clear ];

  	glGenTextures(1, &glID);

    width = height = 0;
    dataFormat = NpImageDataFormatUnknown;
    pixelFormat = NpImagePixelFormatUnknown;

    reset_texture2d_filterstate(&filterState);
    reset_texture2d_wrapstate(&wrapState);
}

- (BOOL) loadFromStream:(id <NPPStream>)stream 
                  error:(NSError **)error
{
    return NO;
}

- (BOOL) loadFromFile:(NSString *)fileName
                 sRGB:(BOOL)sRGB
                error:(NSError **)error
{
    /*
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
    */

    [ self setName:fileName ];

    NPImage * image = AUTORELEASE([[ NPImage alloc ] init ]);
    if ( [ image loadFromFile:fileName
                         sRGB:sRGB
                        error:error ] == NO )
    {
        return NO;
    }

    return YES;
}

- (BOOL) loadFromFile:(NSString *)fileName
                error:(NSError **)error
{
    return [ self loadFromFile:fileName
                          sRGB:NO
                         error:error ];
}

- (void) uploadToGLWithoutData
{
    [ self uploadToGLWithData:[ NSData data ]];
}

- (void) uploadToGLWithData:(NSData *)data
{
}

- (NpTextureType) textureType
{
    return NpTextureTypeTexture2D;
}

- (GLuint) glID
{
    return 0;
}

- (GLenum) glTarget
{
    return GL_TEXTURE_2D;
}

@end

