#import "GL/glew.h"
#import "Core/NPObject/NPObject.h"
#import "Core/Protocols/NPPPersistentObject.h"
#import "Graphics/NPEngineGraphicsEnums.h"
#import "NPPTexture.h"

typedef struct NpTexture2DFilterState
{
	BOOL mipmaps;
	NpTexture2DFilter textureFilter;
	uint32_t anisotropy;
}
NpTexture2DFilterState;

typedef struct NpTexture2DWrapState
{
	NpTextureWrap wrapS;
	NpTextureWrap wrapT;
}
NpTexture2DWrapState;

void reset_texture2d_filterstate(NpTexture2DFilterState * filterState);
void reset_texture2d_wrapstate(NpTexture2DWrapState * wrapState);

@class NSData;
@class NPImage;

@interface NPTexture2D : NPObject < NPPPersistentObject, NPPTexture >
{
    NSString * file;
    BOOL ready;

    uint32_t width;
    uint32_t height;

    NpTextureDataFormat dataFormat;
    NpTexturePixelFormat pixelFormat;
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
- (NpTextureDataFormat) dataFormat;
- (NpTexturePixelFormat) pixelFormat;

- (void) setTextureFilter:(NpTexture2DFilter)newTextureFilter;
- (void) setTextureAnisotropy:(uint32_t)newTextureAnisotropy;

- (void) generateMipMaps;

- (void) generateUsingWidth:(uint32_t)newWidth
                     height:(uint32_t)newHeight
                pixelFormat:(NpTexturePixelFormat)newPixelFormat
                 dataFormat:(NpTextureDataFormat)newDataFormat
                    mipmaps:(BOOL)newMipmaps
                       data:(NSData *)data
                           ;

- (void) generateUsingImage:(NPImage *)image;

@end

