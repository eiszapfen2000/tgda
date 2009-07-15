#import "Core/NPObject/NPObject.h"

@class NPRenderBuffer;
@class NPRenderTexture;
@class NPTexture;

@interface NPRenderTargetConfiguration : NPObject
{
	UInt fboID;

	Int width;
	Int height;

	NSMutableArray * colorTargets;
	NPRenderBuffer * depth;
    NPRenderBuffer * stencil;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (Int) width;
- (Int) height;
- (NSMutableArray *) colorTargets;

- (void) setWidth:(Int)newWidth;
- (void) setHeight:(Int)newHeight;

- (void) clear;
- (void) resetColorTargetsArray;

- (void) generateGLFBOID;
- (UInt) fboID;
- (UInt) colorBufferIndexForRenderTexture:(NPRenderTexture *)renderTexture;
- (NPRenderTexture *) renderTextureAtIndex:(Int)colorBufferIndex;

- (void) copyColorBuffer:(Int)colorBufferIndex toTexture:(NPTexture *)texture;

- (void) setDepthRenderTarget:(NPRenderBuffer *)newDepthRenderTarget;
- (void) setStencilRenderTarget:(NPRenderBuffer *)newStencilRenderTarget;
- (void) setDepthStencilRenderTarget:(NPRenderBuffer *)newDepthStencilRenderTarget;
- (void) setColorRenderTarget:(NPRenderTexture *)newColorRenderTarget atIndex:(Int)colorBufferIndex;

- (BOOL) checkFrameBufferCompleteness;

- (void) bindFBO;
- (void) unbindFBO;
- (void) activateDrawBuffers;
- (void) deactivateDrawBuffers;
- (void) activateViewport;
- (void) deactivateViewport;

- (void) activate;
- (void) deactivate;

@end
