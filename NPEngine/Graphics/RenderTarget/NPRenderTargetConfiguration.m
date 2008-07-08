#import "NPRenderTargetConfiguration.h"
#import "NPRenderBuffer.h"
#import "NPRenderTexture.h"
#import "Graphics/npgl.h"
#import "Core/NPEngineCore.h"

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

            ready = NO;
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

- (void) setColorRenderTarget:(NPRenderTexture *)newColorRenderTarget atIndex:(Int)colorBufferIndex
{
    if ( [ newColorRenderTarget type ] == NP_RENDERTEXTURE_COLOR_TYPE )
    {
        [ colorTargets insertObject:newColorRenderTarget atIndex:colorBufferIndex ];

        [ newColorRenderTarget bindToRenderTargetConfiguration:self colorBufferIndex:colorBufferIndex ];
    }
}

- (void) activate
{
    GLenum buffers[8];
    Int bufferCount = 0;

    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, fboID);

    for ( Int i = 0; i < [ colorTargets count ]; i++ )
    {
        if ( [ colorTargets objectAtIndex:i ] != nil )
        {
            buffers[bufferCount] = GL_COLOR_ATTACHMENT0_EXT + i;
            bufferCount++;
        }
    }

    glDrawBuffers(bufferCount,buffers);
}

- (void) deactivate
{
    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
    glDrawBuffer(GL_BACK);
}

- (BOOL) checkFrameBufferCompleteness
{
    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, fboID);

    NPState status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT);

    NSString * message;

    BOOL tmp = NO;

    switch ( status )
    {
        case GL_FRAMEBUFFER_COMPLETE_EXT: { message = @"FBO OK"; tmp = YES; break; }
        case GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT_EXT: { message = @"FBO Attachment error"; break; }
        case GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT_EXT: { message = @"FBO missing attachment"; break; }
        case GL_FRAMEBUFFER_INCOMPLETE_DUPLICATE_ATTACHMENT_EXT: { message = @"FBO duplicate attachment"; break; }
        case GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS_EXT: { message = @"FBO wrong dimensions"; break; }
        case GL_FRAMEBUFFER_INCOMPLETE_FORMATS_EXT: { message = @"FBO wrong format"; break; }
        case GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER_EXT: { message = @"FBO draw buffer error"; break; }
        case GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER_EXT: { message = @"FBO read buffer error"; break; }
        case GL_FRAMEBUFFER_UNSUPPORTED_EXT: { message = @"FBO unsupported format"; break; }
        case GL_FRAMEBUFFER_STATUS_ERROR_EXT: { message = @"FBO status error"; break; }
    }

    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);

    NPLOG_ERROR(message);
    return tmp;
}


@end
