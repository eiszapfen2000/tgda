#import "GL/glew.h"
#import "Core/NPObject/NPObject.h"
#import "NPPRenderTarget.h"
#import "Graphics/NPEngineGraphicsEnums.h"

@class NSError;
@class NPRenderTargetConfiguration;
@class NPTexture2D;

@interface NPRenderTexture : NPObject < NPPRenderTarget >
{
	GLuint glID;
    NpRenderTargetType type;
	uint32_t width;
	uint32_t height;
    NpTexturePixelFormat pixelFormat;
    NpTextureDataFormat dataFormat;
    NPTexture2D * texture;
    NPRenderTargetConfiguration * rtc;
    uint32_t colorBufferIndex;
    BOOL ready;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (NPTexture2D *) texture;

- (BOOL) generate:(NpRenderTargetType)newType
            width:(uint32_t)newWidth
           height:(uint32_t)newHeight
      pixelFormat:(NpTexturePixelFormat)newPixelFormat
       dataFormat:(NpTextureDataFormat)newDataFormat
    mipmapStorage:(BOOL)mipmapStorage
            error:(NSError **)error
                 ;

@end

