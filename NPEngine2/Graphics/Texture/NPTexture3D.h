#import "GL/glew.h"
#import "Core/NPObject/NPObject.h"
#import "Core/Protocols/NPPPersistentObject.h"
#import "Graphics/NPEngineGraphicsEnums.h"
#import "NPPTexture.h"

typedef struct NpTexture3DFilterState
{
	BOOL mipmaps;
	NpTextureFilter textureFilter;
	uint32_t anisotropy;
}
NpTexture3DFilterState;

typedef struct NpTexture3DWrapState
{
	NpTextureWrap wrapS;
	NpTextureWrap wrapT;
	NpTextureWrap wrapR;
}
NpTexture3DWrapState;

void reset_texture3d_filterstate(NpTexture3DFilterState * filterState);
void reset_texture3d_wrapstate(NpTexture3DWrapState * wrapState);

@class NSData;
@class NPImage;
@class NPBufferObject;

@interface NPTexture3D : NPObject < NPPPersistentObject, NPPTexture >
{
    BOOL ready;

    uint32_t width;
    uint32_t height;
    uint32_t depth;

    NpTextureDataFormat dataFormat;
    NpTexturePixelFormat pixelFormat;
    NpTextureColorFormat colorFormat;
    NpTexture3DFilterState filterState;
    NpTexture3DWrapState wrapState;

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
- (uint32_t) depth;
- (NpTextureDataFormat) dataFormat;
- (NpTexturePixelFormat) pixelFormat;
- (NpTextureColorFormat) colorFormat;

- (void) setColorFormat:(NpTextureColorFormat)newColorFormat;
- (void) setTextureFilter:(NpTexture2DFilter)newTextureFilter;
- (void) setTextureWrap:(NpTextureWrap)newTextureWrap;
- (void) setTextureAnisotropy:(uint32_t)newTextureAnisotropy;

- (void) generateUsingWidth:(uint32_t)newWidth
                     height:(uint32_t)newHeight
                      depth:(uint32_t)newDepth
                pixelFormat:(NpTexturePixelFormat)newPixelFormat
                 dataFormat:(NpTextureDataFormat)newDataFormat
                    mipmaps:(BOOL)newMipmaps
                       data:(NSData *)data
                           ;

- (void) generateUsingWidth:(uint32_t)newWidth
                     height:(uint32_t)newHeight
                     depth:(uint32_t)newDepth
                pixelFormat:(NpTexturePixelFormat)newPixelFormat
                 dataFormat:(NpTextureDataFormat)newDataFormat
                    mipmaps:(BOOL)newMipmaps
               bufferObject:(NPBufferObject *)bufferObject
                           ;

@end

