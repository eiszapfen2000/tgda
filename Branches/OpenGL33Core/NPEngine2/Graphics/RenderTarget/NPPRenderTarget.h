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

- (void)       attachLevel:(uint32_t)newLevel
 renderTargetConfiguration:(NPRenderTargetConfiguration *)configuration
          colorBufferIndex:(uint32_t)newColorBufferIndex
                   bindFBO:(BOOL)bindFBO
                          ;

- (void) detach:(BOOL)bindFBO;

@end

@protocol NPPRenderTarget3D < NPPRenderTarget2D >

- (uint32_t) depth;

- (void)       attachLevel:(uint32_t)newLevel
                     layer:(uint32_t)newLayer
 renderTargetConfiguration:(NPRenderTargetConfiguration *)configuration
          colorBufferIndex:(uint32_t)newColorBufferIndex
                   bindFBO:(BOOL)bindFBO
                          ;

@end
