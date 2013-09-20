#import "Core/NPObject/NPObject.h"
#import "GL/glew.h"

@class NPRenderTargetConfiguration;

@protocol NPPRenderTarget2D < NSObject >

- (GLuint) glID;
- (uint32_t) width;
- (uint32_t) height;

- (void) attachToRenderTargetConfiguration:(NPRenderTargetConfiguration *)configuration
                          colorBufferIndex:(uint32_t)newColorBufferIndex
                                   bindFBO:(BOOL)bindFBO
                                          ;

- (void) detach:(BOOL)bindFBO;

@end
