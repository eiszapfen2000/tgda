#import "GL/glew.h"
#import "Core/NPObject/NPObject.h"
#import "Graphics/NPEngineGraphicsEnums.h"

@class NSError;
@class NPRenderTargetConfiguration;

@interface NPRenderBuffer : NPObject
{
	GLuint glID;
    NpRenderTargetType type;
	uint32_t width;
	uint32_t height;
    NpImagePixelFormat pixelFormat;
    NpRenderBufferDataFormat dataFormat;
    BOOL ready;
    NPRenderTargetConfiguration * rtc;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (GLuint) glID;
- (uint32_t) width;
- (uint32_t) height;

- (BOOL) generate:(NpRenderTargetType)newType
            width:(uint32_t)newWidth
           height:(uint32_t)newHeight
      pixelFormat:(NpImagePixelFormat)newPixelFormat
       dataFormat:(NpRenderBufferDataFormat)newDataFormat
            error:(NSError **)error
                 ;

- (void) attachToRenderTargetConfiguration:(NPRenderTargetConfiguration *)configuration
                                   bindFBO:(BOOL)bindFBO
                                          ;
- (void) detach:(BOOL)bindFBO;

@end

