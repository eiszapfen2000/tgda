#import "GL/glew.h"
#import "Core/NPObject/NPObject.h"
#import "Core/Protocols/NPPPersistentObject.h"
#import "Graphics/NPEngineGraphicsEnums.h"
#import "NPPTexture.h"
#import "NPTexture2D.h"

@class NSData;
@class NPImage;
@class NPBufferObject;

@interface NPTexture2DArray : NPObject < NPPPersistentObject, NPPTexture >
{
    BOOL ready;

    uint32_t width;
    uint32_t height;
    uint32_t layers;

    NpTextureDataFormat dataFormat;
    NpTexturePixelFormat pixelFormat;
    NpTextureColorFormat colorFormat;
    NpTexture2DFilterState filterState;
    NpTexture2DWrapState wrapState;

    GLuint glID;
    GLenum glDataFormat;
    GLenum glPixelFormat;
    GLint  glInternalFormat;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (void) clear;
- (void) reset;

- (uint32_t) width;
- (uint32_t) height;
- (uint32_t) layers;
- (NpTextureDataFormat) dataFormat;
- (NpTexturePixelFormat) pixelFormat;
- (NpTextureColorFormat) colorFormat;

- (void) setColorFormat:(NpTextureColorFormat)newColorFormat;
- (void) setTextureFilter:(NpTexture2DFilter)newTextureFilter;
- (void) setTextureWrap:(NpTextureWrap)newTextureWrap;
- (void) setTextureAnisotropy:(uint32_t)newTextureAnisotropy;

- (void) generateMipMaps;

- (void) generateUsingWidth:(uint32_t)newWidth
                     height:(uint32_t)newHeight
                     layers:(uint32_t)newLayers
                pixelFormat:(NpTexturePixelFormat)newPixelFormat
                 dataFormat:(NpTextureDataFormat)newDataFormat
                    mipmaps:(BOOL)newMipmaps
                       data:(NSData *)data
                           ;

- (void) generateUsingWidth:(uint32_t)newWidth
                     height:(uint32_t)newHeight
                     layers:(uint32_t)newLayers
                pixelFormat:(NpTexturePixelFormat)newPixelFormat
                 dataFormat:(NpTextureDataFormat)newDataFormat
                    mipmaps:(BOOL)newMipmaps
               bufferObject:(NPBufferObject *)bufferObject
                           ;

@end

