#import <Foundation/NSData.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import "Log/NPLog.h"
#import "Core/Container/NPAssetArray.h"
#import "Core/Utilities/NSError+NPEngine.h"
#import "Core/NPEngineCore.h"
#import "Graphics/Buffer/NPBufferObject.h"
#import "Graphics/Image/NPImage.h"
#import "Graphics/NPEngineGraphicsErrors.h"
#import "Graphics/NPEngineGraphicsEnums.h"
#import "Graphics/NPEngineGraphicsStringEnumConversion.h"
#import "Graphics/NSString+NPEngineGraphicsEnums.h"
#import "Graphics/NPEngineGraphics.h"
#import "NpTextureSamplerParameter.h"
#import "NPTextureBindingState.h"
#import "NPTexture2DArray.h"

@interface NPTexture2DArray (Private)

- (void) updateGLTextureState;
- (void) uploadToGLWithData:(NSData *)data;
- (void) uploadToGLWithBufferObject:(NPBufferObject *)bufferObject;
- (void) uploadToGL:(const GLvoid *)data allowNull:(BOOL)allowNull;

@end

@implementation NPTexture2DArray

- (id) init
{
    return [ self initWithName:@"Texture2DArray" ];
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

    [ super dealloc ];
}

- (BOOL) ready
{
    return ready;
}

- (NSString *) fileName
{
    return nil;
}

- (void) clear
{
    [ self reset ];
}

- (void) reset
{
    ready = NO;
    width = height = layers = 0;
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

- (uint32_t) layers
{
    return layers;
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

    glTexParameteri(GL_TEXTURE_2D_ARRAY, GL_TEXTURE_MAX_LEVEL, 1000);
    glGenerateMipmap(GL_TEXTURE_2D_ARRAY);

    [[[ NPEngineGraphics instance ] textureBindingState ] restoreOriginalTextureImmediately ];
}

- (void) generateUsingWidth:(uint32_t)newWidth
                     height:(uint32_t)newHeight
                     layers:(uint32_t)newLayers
                pixelFormat:(NpTexturePixelFormat)newPixelFormat
                 dataFormat:(NpTextureDataFormat)newDataFormat
                    mipmaps:(BOOL)newMipmaps
                       data:(NSData *)data
{
    if ( width != newWidth || height != newHeight || layers != newLayers
        || pixelFormat != newPixelFormat || dataFormat != newDataFormat )
    {
        ready = NO;
        width  = newWidth;
        height = newHeight;
        layers = newLayers;
        pixelFormat = newPixelFormat;
        dataFormat  = newDataFormat;
        colorFormat = getColorFormatForPixelFormat(newPixelFormat);
    }

    filterState.mipmaps = newMipmaps;

    [ self uploadToGLWithData:data ];

    ready = YES;
}

- (void) generateUsingWidth:(uint32_t)newWidth
                     height:(uint32_t)newHeight
                     layers:(uint32_t)newLayers
                pixelFormat:(NpTexturePixelFormat)newPixelFormat
                 dataFormat:(NpTextureDataFormat)newDataFormat
                    mipmaps:(BOOL)newMipmaps
               bufferObject:(NPBufferObject *)bufferObject
{
    if ( width != newWidth || height != newHeight || layers != newLayers
        || pixelFormat != newPixelFormat || dataFormat != newDataFormat )
    {
        ready = NO;
        width  = newWidth;
        height = newHeight;
        layers = newLayers;
        pixelFormat = newPixelFormat;
        dataFormat  = newDataFormat;
        colorFormat = getColorFormatForPixelFormat(newPixelFormat);
    }

    filterState.mipmaps = newMipmaps;

    [ self uploadToGLWithBufferObject:bufferObject ];

    ready = YES;
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
    return NO;
}

// NPPTexture protocol implementation

- (NpTextureType) textureType
{
    return NpTextureTypeTexture2DArray;
}

- (GLuint) glID
{
    return glID;
}

- (GLenum) glTarget
{
    return GL_TEXTURE_2D_ARRAY;
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

@implementation NPTexture2DArray (Private)

- (void) updateGLTextureState
{
    /*
    [[[ NPEngineGraphics instance ] textureBindingState ] setTextureImmediately:self ];

    set_texture2d_filter(filterState.textureFilter);
    set_texture2d_anisotropy(filterState.anisotropy);
    set_texture2d_wrap(wrapState.wrapS, wrapState.wrapT);
    set_texture2d_swizzle_mask(colorFormat);

    [[[ NPEngineGraphics instance ] textureBindingState ] restoreOriginalTextureImmediately ];
    */
}

- (void) uploadToGLWithData:(NSData *)data
{
    [[[ NPEngineGraphics instance ] textureBindingState ] setTextureImmediately:self ];

    const GLvoid * glData = [ data bytes ];
    [ self uploadToGL:glData allowNull:NO ];

    [[[ NPEngineGraphics instance ] textureBindingState ] restoreOriginalTextureImmediately ];
}

- (void) uploadToGLWithBufferObject:(NPBufferObject *)bufferObject
{
    [[[ NPEngineGraphics instance ] textureBindingState ] setTextureImmediately:self ];
    glBindBuffer(GL_PIXEL_UNPACK_BUFFER, [bufferObject glID]);

    [ self uploadToGL:NULL allowNull:YES ];

    glBindBuffer(GL_PIXEL_UNPACK_BUFFER, 0);
    [[[ NPEngineGraphics instance ] textureBindingState ] restoreOriginalTextureImmediately ];
}

- (void) uploadToGL:(const GLvoid *)data allowNull:(BOOL)allowNull
{
    if ( ready == YES )
    {
        // glTexSubImage2D does not handle NULL
        if ( allowNull == YES || data != NULL )
        {
            //update data, is a lot faster than glTexImage2D
            glTexSubImage3D(GL_TEXTURE_2D_ARRAY, 0, 0, 0, 0, width, height,
                layers, glPixelFormat, glDataFormat, data);

            if ( filterState.mipmaps == YES )
            {
                glGenerateMipmap(GL_TEXTURE_2D_ARRAY);
            }
        }
    }
    else
    {
        glInternalFormat
            = getGLTextureInternalFormat(dataFormat, pixelFormat, YES,
                 &glDataFormat, &glPixelFormat);

        // specify entire texture
        glTexImage3D(GL_TEXTURE_2D_ARRAY, 0, glInternalFormat, width, height, 
            layers, 0, glPixelFormat, glDataFormat, data);

        // this is here because of broken AMD drivers
        // if the call is moved somewhere else mipmap
        // generation does not work
        if ( filterState.mipmaps == YES )
        {
            glGenerateMipmap(GL_TEXTURE_2D_ARRAY);
        }
        else
        {
            glTexParameteri(GL_TEXTURE_2D_ARRAY, GL_TEXTURE_MAX_LEVEL, 0);
        }

        /*
        set_texture2d_filter(filterState.textureFilter);
        set_texture2d_anisotropy(filterState.anisotropy);
        set_texture2d_wrap(wrapState.wrapS, wrapState.wrapT);
        set_texture2d_swizzle_mask(colorFormat);
        */
    }
}

@end

