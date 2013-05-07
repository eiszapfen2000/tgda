#import <Foundation/NSData.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
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
#import "NpTextureSamplerParameter.h"
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

    glGenTextures(1, &glID);
    [ self reset ];

    return self;
}

- (void) dealloc
{
    [[[ NPEngineGraphics instance ] textures2D ] unregisterAsset:self ];

    if (glID > 0 )
    {
        glDeleteTextures(1, &glID);
        glID = 0;
    }

    SAFE_DESTROY(file);

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
    [ self reset ];
}

- (void) reset
{
    ready = NO;
    width = height = 0;
    dataFormat  = NpImageDataFormatUnknown;
    pixelFormat = NpImagePixelFormatUnknown;
    colorFormat = NpTextureColorFormatUnknown;
    glDataFormat = GL_NONE;
    glPixelFormat = GL_NONE;
    glInternalFormat = GL_NONE;

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

- (NpTextureColorFormat) colorFormat
{
    return colorFormat;
}

- (void) setColorFormat:(NpTextureColorFormat)newColorFormat
{
    if ( colorFormat != newColorFormat )
    {
        colorFormat = newColorFormat;
        [ self updateGLTextureState ];
    }
}

- (void) setTextureFilter:(NpTexture2DFilter)newTextureFilter
{
    if ( filterState.textureFilter != newTextureFilter )
    {
        filterState.textureFilter = newTextureFilter;
        [ self updateGLTextureState ];
    }
}

- (void) setTextureWrap:(NpTextureWrap)newTextureWrap
{
    if ( wrapState.wrapS != newTextureWrap
         || wrapState.wrapT != newTextureWrap )
    {
        wrapState.wrapS = newTextureWrap;
        wrapState.wrapT = newTextureWrap;
        [ self updateGLTextureState ];
    }
}

- (void) setTextureAnisotropy:(uint32_t)newTextureAnisotropy
{
    filterState.anisotropy
        = MAX(1, MIN(newTextureAnisotropy,
                         (uint32_t)[[ NPEngineGraphics instance ] maximumAnisotropy ]));

    [ self updateGLTextureState ];
}

- (void) generateMipMaps
{
    [[[ NPEngineGraphics instance ] textureBindingState ] setTextureImmediately:self ];

    glGenerateMipmap(GL_TEXTURE_2D);

    [[[ NPEngineGraphics instance ] textureBindingState ] restoreOriginalTextureImmediately ];
}

- (void) generateUsingWidth:(uint32_t)newWidth
                     height:(uint32_t)newHeight
                pixelFormat:(NpTexturePixelFormat)newPixelFormat
                 dataFormat:(NpTextureDataFormat)newDataFormat
                    mipmaps:(BOOL)newMipmaps
                       data:(NSData *)data
{
    if ( width != newWidth || height != newHeight
        || pixelFormat != newPixelFormat || dataFormat != newDataFormat )
    {
        ready = NO;
        width  = newWidth;
        height = newHeight;
        pixelFormat = newPixelFormat;
        dataFormat  = newDataFormat;
        colorFormat = getColorFormatForPixelFormat(newPixelFormat);
    }

    filterState.mipmaps = newMipmaps;

    [ self uploadToGLWithData:data ];

    ready = YES;
}

- (void) generateUsingImage:(NPImage *)image
{
    [ self generateUsingWidth:[ image width       ]
                       height:[ image height      ]
                  pixelFormat:[ image pixelFormat ]
                   dataFormat:[ image dataFormat  ]
                      mipmaps:filterState.mipmaps
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
                                            completeFileName ];

            *error = [ NSError errorWithCode:NPEngineGraphicsTextureUnableToLoadImage
                                 description:errorString ];
        }

        return NO;
    }

    // default if loading from file, generate mipmaps
    // and do trilinear filtering
    filterState.textureFilter = NpTexture2DFilterTrilinear;
    filterState.mipmaps = YES;

    // process optional arguments
    if ( arguments != nil )
    {
        NSString * mipmapString = [ arguments objectForKey:@"Mipmaps" ];
        NSString * filterString = [ arguments objectForKey:@"Filter"  ];

        if ( mipmapString != nil )
        {
            filterState.mipmaps = [ mipmapString boolValue ];
        }

        if ( filterString != nil )
        {
            filterState.textureFilter
                = [[ filterString lowercaseString ]
                        textureFilterValueWithDefault:NpTexture2DFilterTrilinear ];
        }
    }

    [ self generateUsingImage:image ];

    DESTROY(image);

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

static const GLint masks[][4]
    = {
        {GL_RED, GL_RED, GL_RED, GL_ZERO},
        {GL_RED, GL_RED, GL_RED, GL_ONE},
        {GL_GREEN, GL_GREEN, GL_GREEN, GL_ZERO},
        {GL_GREEN, GL_GREEN, GL_GREEN, GL_ONE},
        {GL_BLUE, GL_BLUE, GL_BLUE, GL_ZERO},
        {GL_BLUE, GL_BLUE, GL_BLUE, GL_ONE},
        {GL_ALPHA, GL_ALPHA, GL_ALPHA, GL_ZERO},
        {GL_ALPHA, GL_ALPHA, GL_ALPHA, GL_ONE},
        {GL_RED, GL_GREEN, GL_ZERO, GL_ZERO},
        {GL_RED, GL_GREEN, GL_ZERO, GL_ONE},
        {GL_RED, GL_GREEN, GL_BLUE, GL_ZERO},
        {GL_RED, GL_GREEN, GL_BLUE, GL_ONE},
        {GL_RED, GL_GREEN, GL_BLUE, GL_ALPHA}
      };

@implementation NPTexture2D (Private)

- (void) updateGLTextureState
{
    [[[ NPEngineGraphics instance ] textureBindingState ] setTextureImmediately:self ];

    set_texture2d_filter(filterState.textureFilter);
    set_texture2d_anisotropy(filterState.anisotropy);
    set_texture2d_wrap(wrapState.wrapS, wrapState.wrapT);
    set_texture2d_swizzle_mask(colorFormat);

    [[[ NPEngineGraphics instance ] textureBindingState ] restoreOriginalTextureImmediately ];
}

- (void) uploadToGLWithData:(NSData *)data
{
    [[[ NPEngineGraphics instance ] textureBindingState ] setTextureImmediately:self ];

    const GLvoid * glData = [ data bytes ];

    if ( ready == YES )
    {
        // glTexSubImage2D does not handle NULL
        if ( glData != NULL )
        {
            //update data, is a lot faster than glTexImage2D
            glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height,
                glPixelFormat, glDataFormat, glData);
        }
    }
    else
    {
        glInternalFormat
            = getGLTextureInternalFormat(dataFormat, pixelFormat, YES,
                 &glDataFormat, &glPixelFormat);

        // specify entire texture
        glTexImage2D(GL_TEXTURE_2D, 0, glInternalFormat, width, height, 
            0, glPixelFormat, glDataFormat, glData);

        // this is here because of broken AMD drivers
        // if the call is moved somewhere else mipmap
        // generation does not work
        if ( filterState.mipmaps == YES )
        {
            glGenerateMipmap(GL_TEXTURE_2D);
        }

        set_texture2d_filter(filterState.textureFilter);
        set_texture2d_anisotropy(filterState.anisotropy);
        set_texture2d_wrap(wrapState.wrapS, wrapState.wrapT);
        set_texture2d_swizzle_mask(colorFormat);
    }

    [[[ NPEngineGraphics instance ] textureBindingState ] restoreOriginalTextureImmediately ];
}

@end

