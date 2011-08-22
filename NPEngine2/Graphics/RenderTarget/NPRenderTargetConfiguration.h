#import "GL/glew.h"
#import "Core/NPObject/NPObject.h"

@class NSError;
@class NSMutableArray;
@class NPRenderBuffer;
@class NPRenderTexture;

@interface NPRenderTargetConfiguration : NPObject
{
	GLuint glID;

	uint32_t width;
	uint32_t height;

    NSMutableArray * colorTargets;
    NPRenderBuffer * depthStencil;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (GLuint) glID;
- (uint32_t) width;
- (uint32_t) height;
- (void) setWidth:(uint32_t)newWidth;
- (void) setHeight:(uint32_t)newHeight;

- (void) bindFBO;
- (void) unbindFBO;

- (void) setColorTarget:(NPRenderTexture *)colorTarget
                atIndex:(uint32_t)index
                       ;

- (void) setDepthStencilTarget:(NPRenderBuffer *)depthStencilTarget;

- (BOOL) checkFrameBufferCompleteness:(NSError **)error;

- (void) activateDrawBuffers;
- (void) deactivateDrawBuffers;
- (void) activateViewport;
- (void) deactivateViewport;
- (void) activate;
- (void) deactivate;

@end
