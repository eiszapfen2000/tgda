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
#import "NPTexture3D.h"

void reset_texture3d_filterstate(NpTexture3DFilterState * filterState)
{
    filterState->mipmaps = NO;
    filterState->textureFilter = NpTextureFilterNearest;
    filterState->anisotropy = 1;
}

void reset_texture3d_wrapstate(NpTexture3DWrapState * wrapState)
{
    wrapState->wrapS = NpTextureWrapToEdge;
    wrapState->wrapT = NpTextureWrapToEdge;
    wrapState->wrapR = NpTextureWrapToEdge;
}

@interface NPTexture3D (Private)

- (void) updateGLTextureState;
- (void) uploadToGLWithData:(NSData *)data;
- (void) uploadToGLWithBufferObject:(NPBufferObject *)bufferObject;
- (void) uploadToGL:(const GLvoid *)data allowNull:(BOOL)allowNull;

@end

@implementation NPTexture3D

- (id) init
{
    return [ self initWithName:@"Texture3D" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];
    [[[ NPEngineGraphics instance ] textures3D ] registerAsset:self ];

    glGenTextures(1, &glID);
    [ self reset ];

    return self;
}

- (void) dealloc
{
    [[[ NPEngineGraphics instance ] textures3D ] unregisterAsset:self ];

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
    width = height = depth = 0;
    dataFormat  = NpImageDataFormatUnknown;
    pixelFormat = NpImagePixelFormatUnknown;
    colorFormat = NpTextureColorFormatUnknown;
    glDataFormat = GL_NONE;
    glPixelFormat = GL_NONE;
    glInternalFormat = GL_NONE;

    reset_texture3d_filterstate(&filterState);
    reset_texture3d_wrapstate(&wrapState);
}

- (uint32_t) width
{
    return width;
}

- (uint32_t) height
{
    return height;
}

- (uint32_t) depth
{
    return depth;
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
         || wrapState.wrapT != newTextureWrap
         || wrapState.wrapR != newTextureWrap )
    {
        wrapState.wrapS = newTextureWrap;
        wrapState.wrapT = newTextureWrap;
        wrapState.wrapR = newTextureWrap;

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

    glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MAX_LEVEL, 1000);
    glGenerateMipmap(GL_TEXTURE_3D);

    [[[ NPEngineGraphics instance ] textureBindingState ] restoreOriginalTextureImmediately ];
}

- (void) generateUsingWidth:(uint32_t)newWidth
                     height:(uint32_t)newHeight
                      depth:(uint32_t)newDepth
                pixelFormat:(NpTexturePixelFormat)newPixelFormat
                 dataFormat:(NpTextureDataFormat)newDataFormat
                    mipmaps:(BOOL)newMipmaps
                       data:(NSData *)data
{
    if ( width != newWidth || height != newHeight || depth != newDepth
        || pixelFormat != newPixelFormat || dataFormat != newDataFormat )
    {
        ready = NO;
        width  = newWidth;
        height = newHeight;
        depth  = newDepth;
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
                      depth:(uint32_t)newDepth
                pixelFormat:(NpTexturePixelFormat)newPixelFormat
                 dataFormat:(NpTextureDataFormat)newDataFormat
                    mipmaps:(BOOL)newMipmaps
               bufferObject:(NPBufferObject *)bufferObject
{
    if ( width != newWidth || height != newHeight || depth != newDepth
        || pixelFormat != newPixelFormat || dataFormat != newDataFormat )
    {
        ready = NO;
        width  = newWidth;
        height = newHeight;
        depth  = newDepth;
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
    return NpTextureTypeTexture3D;
}

- (GLuint) glID
{
    return glID;
}

- (GLenum) glTarget
{
    return GL_TEXTURE_3D;
}

@end

@implementation NPTexture3D (Private)

- (void) updateGLTextureState
{
    [[[ NPEngineGraphics instance ] textureBindingState ] setTextureImmediately:self ];

    set_texture3d_filter(filterState.textureFilter);
    set_texture3d_anisotropy(filterState.anisotropy);
    set_texture3d_wrap(wrapState.wrapS, wrapState.wrapT, wrapState.wrapR);
    set_texture3d_swizzle_mask(colorFormat);

    [[[ NPEngineGraphics instance ] textureBindingState ] restoreOriginalTextureImmediately ];
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
            glTexSubImage3D(GL_TEXTURE_3D, 0, 0, 0, 0, width, height,
                depth, glPixelFormat, glDataFormat, data);
        }
    }
    else
    {
        glInternalFormat
            = getGLTextureInternalFormat(dataFormat, pixelFormat, YES,
                 &glDataFormat, &glPixelFormat);

        // specify entire texture
        glTexImage3D(GL_TEXTURE_3D, 0, glInternalFormat, width, height, 
            depth, 0, glPixelFormat, glDataFormat, data);

        // this is here because of broken AMD drivers
        // if the call is moved somewhere else mipmap
        // generation does not work
        if ( filterState.mipmaps == YES )
        {
            glGenerateMipmap(GL_TEXTURE_3D);
        }
        else
        {
            glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MAX_LEVEL, 0);
        }

        set_texture3d_filter(filterState.textureFilter);
        set_texture3d_anisotropy(filterState.anisotropy);
        set_texture3d_wrap(wrapState.wrapS, wrapState.wrapT, wrapState.wrapR);
        set_texture3d_swizzle_mask(colorFormat);
    }
}

@end

