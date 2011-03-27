#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSData.h>
#import "Log/NPLog.h"
#import "Core/Container/NPAssetArray.h"
#import "Core/Utilities/NSError+NPEngine.h"
#import "Core/NPEngineCore.h"
#import "Graphics/Image/NPImage.h"
#import "Graphics/NPEngineGraphicsErrors.h"
#import "Graphics/NPEngineGraphicsEnums.h"
#import "Graphics/NPEngineGraphicsStringEnumConversion.h"
#import "Graphics/NSString+NPEngineGraphicsEnums.h"
#import "Graphics/NPEngineGraphics.h"
#import "NPTextureBindingState.h"
#import "NPTexture2D.h"

void reset_texture2d_filterstate(NpTexture2DFilterState * filterState)
{
    filterState->mipmaps = NO;
    filterState->textureFilter = NpTexture2DFilterNearest;
    filterState->anisotropy = 1;
}

void reset_texture2d_wrapstate(NpTexture2DWrapState * wrapState)
{
    wrapState->wrapS = NpTextureWrapToEdge;
    wrapState->wrapT = NpTextureWrapToEdge;
}

@interface NPTexture2D (Private)

- (void) updateGLTextureFilterState;
- (void) updateGLTextureAnisotropy;
- (void) updateGLTextureWrapState;
- (void) updateGLTextureState;
- (void) uploadToGLWithData:(NSData *)data;

@end

@implementation NPTexture2D

- (id) init
{
    return [ self initWithName:@"Texture2D" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];
    [[[ NPEngineGraphics instance ] textures2D ] registerAsset:self ];

    [ self reset ];

    return self;
}

- (void) dealloc
{
    [[[ NPEngineGraphics instance ] textures2D ] unregisterAsset:self ];

    [ super dealloc ];
}

- (BOOL) ready
{
    return ready;
}

- (NSString *) fileName
{
    return file;
}

- (void) clear
{
    SAFE_DESTROY(file);
    ready = NO;

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
    dataFormat  = NpImageDataFormatUnknown;
    pixelFormat = NpImagePixelFormatUnknown;

    reset_texture2d_filterstate(&filterState);
    reset_texture2d_wrapstate(&wrapState);
}

- (uint32_t) width
{
    return width;
}

- (uint32_t) height
{
    return height;
}

- (NpTextureDataFormat) dataFormat
{
    return dataFormat;
}

- (NpTexturePixelFormat) pixelFormat
{
    return pixelFormat;
}

- (void) setTextureFilter:(NpTexture2DFilter)newTextureFilter
{
    filterState.textureFilter = newTextureFilter;

    [ self updateGLTextureState ];
}

- (void) setTextureAnisotropy:(uint32_t)newTextureAnisotropy
{
    filterState.anisotropy
        = MAX(1, MIN(newTextureAnisotropy,
                         (uint32_t)[[ NPEngineGraphics instance ] maximumAnisotropy ]));

    [ self updateGLTextureState ];
}

- (void) generateUsingWidth:(uint32_t)newWidth
                     height:(uint32_t)newHeight
                pixelFormat:(NpTexturePixelFormat)newPixelFormat
                 dataFormat:(NpTextureDataFormat)newDataFormat
                       data:(NSData *)data
{
    [ self reset ];

    width  = newWidth;
    height = newHeight;
    pixelFormat = newPixelFormat;
    dataFormat  = newDataFormat;

    [ self uploadToGLWithData:data ];
}

- (void) generateUsingImage:(NPImage *)image
{
    [ self generateUsingWidth:[ image width       ]
                       height:[ image height      ]
                  pixelFormat:[ image pixelFormat ]
                   dataFormat:[ image dataFormat  ]
                         data:[ image imageData   ]];
}

- (BOOL) loadFromStream:(id <NPPStream>)stream 
                  error:(NSError **)error
{
    return NO;
}

- (BOOL) loadFromFile:(NSString *)fileName
            arguments:(NSDictionary *)arguments
                error:(NSError **)error
{
    // check if file is to be found
    NSString * completeFileName
        = [[[ NPEngineCore instance ] localPathManager ] getAbsolutePath:fileName ];

    if ( completeFileName == nil )
    {
        if ( error != NULL )
        {
            *error = [ NSError fileNotFoundError:fileName ];
        }

        return NO;
    }

    [ self setName:completeFileName ];
    ASSIGNCOPY(file, completeFileName);

    NPLOG(@"");
    NPLOG(@"Loading texture \"%@\"", completeFileName);

    NPImage * image = 
        RETAIN([[[ NPEngineGraphics instance ] 
                        images ] getAssetWithFileName:completeFileName
                                            arguments:arguments ]);

    if ( image == nil )
    {
        if ( error != NULL )
        {
            NSString * errorString =
                [ NSString stringWithFormat:@"Unable to load image from \"%@\"",
                                            completeFileName];

            *error = [ NSError errorWithCode:NPEngineGraphicsTextureUnableToLoadImage
                                 description:errorString ];
        }

        return NO;
    }

    [ self generateUsingImage:image ];

    RELEASE(image);

    NSString * p = [ NSString stringForPixelFormat:pixelFormat ];
    NSString * d = [ NSString stringForImageDataFormat:dataFormat ];

    NPLOG(@"Resolution: %u x %u", width, height);
    NPLOG(@"Pixel Format: %@", p);
    NPLOG(@"Data Format: %@", d);

    return YES;
}

// NPPTexture protocol implementation

- (NpTextureType) textureType
{
    return NpTextureTypeTexture2D;
}

- (GLuint) glID
{
    return glID;
}

- (GLenum) glTarget
{
    return GL_TEXTURE_2D;
}

@end

@implementation NPTexture2D (Private)

- (void) updateGLTextureFilterState
{
    GLenum minFilter = GL_NONE;
    GLenum magFilter = GL_NONE;

    switch ( filterState.textureFilter )
    {
        case NpTexture2DFilterNearest:
        {
            minFilter = magFilter = GL_NEAREST;
            break;
        }

        case NpTexture2DFilterLinear:
        {
            minFilter = magFilter = GL_LINEAR;
            break;
        }

        case NpTexture2DFilterTrilinear:
        {
            minFilter = GL_LINEAR_MIPMAP_LINEAR;
            magFilter = GL_LINEAR;
        }
    }

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, minFilter);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, magFilter);
}

- (void) updateGLTextureAnisotropy
{
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT,
                    filterState.anisotropy);
}

- (void) updateGLTextureWrapState
{
    GLenum wrapS = getGLTextureWrap(wrapState.wrapS);
    GLenum wrapT = getGLTextureWrap(wrapState.wrapT);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, wrapS);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, wrapT);
}

- (void) updateGLTextureState
{
    [[[ NPEngineGraphics instance ] textureBindingState ] setTextureImmediately:self ];

    [ self updateGLTextureFilterState ];
    [ self updateGLTextureAnisotropy ];
    [ self updateGLTextureWrapState ];

    [[[ NPEngineGraphics instance ] textureBindingState ] restoreOriginalTextureImmediately ];
}

- (void) uploadToGLWithData:(NSData *)data
{
    GLenum gldataformat = getGLTextureDataFormat(dataFormat);
    GLenum glpixelformat = getGLTexturePixelFormat(pixelFormat);
    GLint  glinternalformat
        = getGLTextureInternalFormat(dataFormat, pixelFormat,
             [[ NPEngineGraphics instance ] supportssRGBTextures ]);

    [[[ NPEngineGraphics instance ] textureBindingState ] setTextureImmediately:self ];

    if ( filterState.mipmaps == YES )
    {
        if ( [[ NPEngineGraphics instance ] supportsSGIGenerateMipMap ] == YES )
        {
            glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP_SGIS, 1);
            glTexImage2D(GL_TEXTURE_2D, 0, glinternalformat, width, height,
                0, glpixelformat, gldataformat, [data bytes]);
            glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP_SGIS, 0);
        }
        else
        {
            gluBuild2DMipmaps(GL_TEXTURE_2D, glinternalformat, width, height,
                glpixelformat, gldataformat, [data bytes]);
        }
    }
    else
    {
        glTexImage2D(GL_TEXTURE_2D, 0, glinternalformat, width, height, 0,
             glpixelformat, gldataformat, [data bytes]);
    }

    [[[ NPEngineGraphics instance ] textureBindingState ] restoreOriginalTextureImmediately ];

    [ self updateGLTextureState ]; 
}

@end

