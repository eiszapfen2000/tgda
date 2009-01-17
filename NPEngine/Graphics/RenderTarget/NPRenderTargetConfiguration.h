#import "Core/NPObject/NPObject.h"

@class NPRenderBuffer;
@class NPRenderTexture;

@interface NPRenderTargetConfiguration : NPObject
{
	UInt fboID;

	Int width;
	Int height;

	NSMutableArray * colorTargets;
	NPRenderBuffer * depth;
    NPRenderBuffer * stencil;

	BOOL ready;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) clear;

- (void) generateGLFBOID;
- (BOOL) ready;
- (UInt) fboID;
- (UInt) colorBufferIndexForRenderTexture:(NPRenderTexture *)renderTexture;
- (NPRenderTexture *) renderTextureAtIndex:(Int)colorBufferIndex;

- (void) setDepthRenderTarget:(NPRenderBuffer *)newDepthRenderTarget;
- (void) setStencilRenderTarget:(NPRenderBuffer *)newStencilRenderTarget;
- (void) setDepthStencilRenderTarget:(NPRenderBuffer *)newDepthStencilRenderTarget;
- (void) setColorRenderTarget:(NPRenderTexture *)newColorRenderTarget atIndex:(Int)colorBufferIndex;

- (BOOL) checkFrameBufferCompleteness;

- (void) activate;
- (void) deactivate;

@end
