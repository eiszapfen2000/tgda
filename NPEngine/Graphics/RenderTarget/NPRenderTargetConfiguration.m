#import "NPRenderTargetConfiguration.h"
#import "NPRenderBuffer.h"
#import "Graphics/npgl.h"

@implementation NPRenderTargetConfiguration

- (id) init
{
    return [ self initWithName:@"NPRenderTargetConfiguration" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

	[ self generateGLFBOID ];

	width = height = -1;

	colorTargets = [[ NSMutableArray alloc ] initWithCapacity:8 ];
	depth = stencil = nil;

	ready = NO;

    return self;
}

- (void) dealloc
{
	[ colorTargets release ];
	[ depth release ];
    [ stencil release ];

	glDeleteFramebuffersEXT(1, &fboID);

    [ super dealloc ];
}

- (void) generateGLFBOID
{
	glGenFramebuffersEXT(1, &fboID);
}

- (UInt) fboID
{
    return fboID;
}

- (BOOL) ready
{
	return ready;
}

- (void) setDepthRenderTarget:(NPRenderBuffer *)newDepthRenderTarget
{
    if ( depth != newDepthRenderTarget && [ newDepthRenderTarget ready ] == YES )
    {
        if ( [ newDepthRenderTarget type ] == NP_RENDERBUFFER_DEPTH_TYPE )
        {
            [ depth release ];
            depth = [ newDepthRenderTarget retain ];
            [ depth bindToRenderTargetConfiguration:self ];
        }
    }
}

- (void) setStencilRenderTarget:(NPRenderBuffer *)newStencilRenderTarget
{
    if ( stencil != newStencilRenderTarget && [ newStencilRenderTarget ready ] == YES )
    {
        if ( [ newStencilRenderTarget type ] == NP_RENDERBUFFER_STENCIL_TYPE )
        {
            [ stencil release ];
            stencil = [ newStencilRenderTarget retain ];
            [ stencil bindToRenderTargetConfiguration:self ];
        }
    }
}

- (void) setDepthStencilRenderTarget:(NPRenderBuffer *)newDepthStencilRenderTarget
{
    if ( stencil != newDepthStencilRenderTarget && depth != newDepthStencilRenderTarget && [ newDepthStencilRenderTarget ready ] == YES )
    {
        if ( [ newDepthStencilRenderTarget type ] == NP_RENDERBUFFER_DEPTH_STENCIL_TYPE )
        {
            [ depth release ];
            [ stencil release ];
            depth = [ newDepthStencilRenderTarget retain ];
            stencil = [ newDepthStencilRenderTarget retain ];
            [ depth bindToRenderTargetConfiguration:self ];
        }
    }
}

@end
