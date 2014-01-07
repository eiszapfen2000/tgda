#import "GL/glew.h"
#import "Core/NPObject/NPObject.h"
#import "NPPRenderTarget.h"
#import "Graphics/NPEngineGraphicsEnums.h"

@class NSError;
@class NPRenderTargetConfiguration;

@interface NPRenderBuffer : NPObject < NPPRenderTarget2D >
{
	GLuint glID;
    NpRenderTargetType type;
	uint32_t width;
	uint32_t height;
    NpTexturePixelFormat pixelFormat;
    NpTextureDataFormat dataFormat;
    NPRenderTargetConfiguration * rtc;
    uint32_t colorBufferIndex;
    BOOL ready;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (BOOL) generate:(NpRenderTargetType)newType
            width:(uint32_t)newWidth
           height:(uint32_t)newHeight
      pixelFormat:(NpTexturePixelFormat)newPixelFormat
       dataFormat:(NpTextureDataFormat)newDataFormat
            error:(NSError **)error
                 ;

@end

