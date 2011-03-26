#import "GL/glew.h"
#import "Core/NPObject/NPObject.h"
#import "Graphics/NPEngineGraphicsEnums.h"

@class NSError;
@class NPRenderTargetConfiguration;
@class NPTexture2D;

@interface NPRenderTexture : NPObject
{
	GLuint glID;
    NpRenderTargetType type;
	uint32_t width;
	uint32_t height;
    NpImagePixelFormat pixelFormat;
    NpRenderBufferDataFormat dataFormat;
    NPTexture2D * texture;
    BOOL ready;
    NPRenderTargetConfiguration * rtc;
    uint32_t colorBufferIndex;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (uint32_t) width;
- (uint32_t) height;

- (BOOL) generate:(NpRenderTargetType)newType
            width:(uint32_t)newWidth
           height:(uint32_t)newHeight
      pixelFormat:(NpTexturePixelFormat)newPixelFormat
       dataFormat:(NpTextureDataFormat)newDataFormat
            error:(NSError **)error
                 ;

- (void) attachToRenderTargetConfiguration:(NPRenderTargetConfiguration *)configuration
                          colorBufferIndex:(uint32_t)newColorBufferIndex
                                          ;
- (void) detach;

@end

