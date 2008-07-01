#import "Core/NPObject/NPObject.h"

#define NP_RENDERBUFFER_DEPTH_TYPE          0
#define NP_RENDERBUFFER_STENCIL_TYPE        1
#define NP_RENDERBUFFER_DEPTH_STENCIL_TYPE  2

#define NP_RENDERBUFFER_DEPTH16 		    0
#define NP_RENDERBUFFER_DEPTH24 		    1
#define NP_RENDERBUFFER_DEPTH32 		    2
#define NP_RENDERBUFFER_STENCIL1            3
#define NP_RENDERBUFFER_STENCIL4            4
#define NP_RENDERBUFFER_STENCIL8            5
#define NP_RENDERBUFFER_STENCIL16           6
#define NP_RENDERBUFFER_DEPTH24_STENCIL8	7

@class NPRenderTargetConfiguration;

@interface NPRenderBuffer : NPObject
{
	UInt renderBufferID;

    Int width;
    Int height;

    NPState type;
	NPState format;

    NPRenderTargetConfiguration * configuration;

    BOOL ready;
}

+ (id) renderBufferWithName:(NSString *)name type:(NPState)type format:(NPState)format width:(Int)width height:(Int)height;

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (void) generateGLRenderBufferID;

- (void) checkForReadiness;
- (BOOL) ready;
- (Int) width;
- (void) setWidth:(Int)newWidth;
- (Int) height;
- (void) setHeight:(Int)newHeight;
- (NPState) type;
- (void) setType:(NPState)newType;
- (NPState) format;
- (void) setFormat:(NPState)newFormat;

- (void) uploadToGL;

- (void) bindToRenderTargetConfiguration:(NPRenderTargetConfiguration *)newConfiguration;
- (void) unbindFromRenderTargetConfiguration;

@end
