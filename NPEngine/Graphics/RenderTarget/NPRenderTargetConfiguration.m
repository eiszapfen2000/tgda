#import "NPRenderTargetConfiguration.h"
#import "NPRenderBuffer.h"
#import "NPRenderTexture.h"
#import "Graphics/npgl.h"
#import "NP.h"

@implementation NPRenderTargetConfiguration

- (id) init
{
    return [ self initWithName:@"NPRenderTargetConfiguration" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

	[ self generateGLFBOID ];

	width = height = -1;

	colorTargets = [[ NSMutableArray alloc ] initWithCapacity:NP_GRAPHICS_SAMPLER_COUNT ];
    for ( Int i = 0; i < NP_GRAPHICS_SAMPLER_COUNT; i++ )
    {
        [ colorTargets addObject:[NSNull null] ];
    }

	depth = stencil = nil;

    return self;
}

- (void) dealloc
{
    [ colorTargets removeAllObjects ];
	[ colorTargets release ];

	glDeleteFramebuffersEXT(1, &fboID);

    [ super dealloc ];
}

- (Int) width
{
    return width;
}

- (Int) height
{
    return height;
}

- (NSMutableArray *) colorTargets
{
    return colorTargets;
}

- (void) setWidth:(Int)newWidth
{
    width = newWidth;
}

- (void) setHeight:(Int)newHeight
{
    height = newHeight;
}

- (void) generateGLFBOID
{
	glGenFramebuffersEXT(1, &fboID);
}

- (UInt) fboID
{
    return fboID;
}

- (UInt) colorBufferIndexForRenderTexture:(NPRenderTexture *)renderTexture
{
    return [ colorTargets indexOfObject:renderTexture ];
}

- (NPRenderTexture *) renderTextureAtIndex:(Int)colorBufferIndex
{
    return [ colorTargets objectAtIndex:colorBufferIndex ];
}

- (void) clear
{
    NSEnumerator * e = [ colorTargets objectEnumerator ];
    id renderTarget;

    while (( renderTarget = [ e nextObject ] ))
    {
        if ( renderTarget != [ NSNull null ] )
        {
            [ renderTarget unbindFromRenderTargetConfiguration ];
        }
    }

    [ self resetColorTargetsArray ];

    if ( depth != nil )
    {
        [ depth unbindFromRenderTargetConfiguration ];
        [ depth release ];
        depth = nil;
    }

    if ( stencil != nil )
    {
        [ stencil release ];
        stencil = nil;
    }
}

- (void) resetColorTargetsArray
{
    for ( Int i = 0; i < NP_GRAPHICS_SAMPLER_COUNT; i++ )
    {
        [ colorTargets replaceObjectAtIndex:i withObject:[NSNull null] ];
    }
}

- (void) copyColorBuffer:(Int)colorBufferIndex toTexture:(NPTexture *)texture
{
    GLenum attachment = GL_COLOR_ATTACHMENT0_EXT + colorBufferIndex;
    glReadBuffer(attachment);

    if ( (width != [ texture width ]) || (height != [ texture height ]) )
    {
        NPLOG_WARNING(@"%@: resolution mismatch between RT Config and texture to copy", name);
        return;
    }

    glBindTexture(GL_TEXTURE_2D, [ texture textureID ]);
    glCopyTexSubImage2D( GL_TEXTURE_2D, 0, 0, 0, 0, 0, width, height );
    glBindTexture( GL_TEXTURE_2D, 0 );
}

- (void) setDepthRenderTarget:(NPRenderBuffer *)newDepthRenderTarget
{
    if ( depth != newDepthRenderTarget )
    {
        if ( [ newDepthRenderTarget type ] == NP_GRAPHICS_RENDERBUFFER_DEPTH_TYPE )
        {
            TEST_RELEASE(depth);
            depth = [ newDepthRenderTarget retain ];

            if ( [ depth width ] > width || [ depth height ] > height )
            {
                width  = [ depth width  ];
                height = [ depth height ];
            }

            [ depth bindToRenderTargetConfiguration:self ];
        }
    }
}

- (void) setStencilRenderTarget:(NPRenderBuffer *)newStencilRenderTarget
{
    if ( stencil != newStencilRenderTarget )
    {
        if ( [ newStencilRenderTarget type ] == NP_GRAPHICS_RENDERBUFFER_STENCIL_TYPE )
        {
            TEST_RELEASE(stencil);
            stencil = [ newStencilRenderTarget retain ];

            if ( [ stencil width ] > width || [ stencil height ] > height )
            {
                width  = [ stencil width  ];
                height = [ stencil height ];
            }

            [ stencil bindToRenderTargetConfiguration:self ];
        }
    }
}

- (void) setDepthStencilRenderTarget:(NPRenderBuffer *)newDepthStencilRenderTarget
{
    if ( stencil != newDepthStencilRenderTarget && depth != newDepthStencilRenderTarget )
    {
        if ( [ newDepthStencilRenderTarget type ] == NP_GRAPHICS_RENDERBUFFER_DEPTH_STENCIL_TYPE )
        {
            TEST_RELEASE(depth);
            TEST_RELEASE(stencil);

            depth   = [ newDepthStencilRenderTarget retain ];
            stencil = [ newDepthStencilRenderTarget retain ];

            if ( [ stencil width ] > width || [ stencil height ] > height )
            {
                width  = [ stencil width  ];
                height = [ stencil height ];
            }

            [ depth bindToRenderTargetConfiguration:self ];
        }
    }
}

- (void) setColorRenderTarget:(NPRenderTexture *)newColorRenderTarget atIndex:(Int)colorBufferIndex
{
    if ( [ newColorRenderTarget type ] == NP_GRAPHICS_RENDERTEXTURE_COLOR_TYPE )
    {
        [ colorTargets replaceObjectAtIndex:colorBufferIndex withObject:newColorRenderTarget ];

        if ( [ newColorRenderTarget width ] > width || [ newColorRenderTarget height ] > height )
        {
            width  = [ newColorRenderTarget width  ];
            height = [ newColorRenderTarget height ];
        }

        [ newColorRenderTarget bindToRenderTargetConfiguration:self colorBufferIndex:colorBufferIndex ];
    }
}

- (void) bindFBO
{
    [[[ NP Graphics ] renderTargetManager ] setCurrentRenderTargetConfiguration:self ];

    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, fboID);
}

- (void) unbindFBO
{
    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);

    [[[ NP Graphics ] renderTargetManager ] setCurrentRenderTargetConfiguration:nil ];
}

- (void) activateDrawBuffers
{
    GLenum buffers[NP_GRAPHICS_DRAWBUFFERS_COUNT];
    Int bufferCount = 0;

    for ( Int i = 0; i < (Int)[ colorTargets count ]; i++ )
    {
        if ( [ colorTargets objectAtIndex:i ] != [ NSNull null ] )
        {
            buffers[bufferCount] = GL_COLOR_ATTACHMENT0_EXT + i;
            bufferCount++;
        }
    }

    glDrawBuffers(bufferCount, buffers);
}

- (void) deactivateDrawBuffers
{
    glDrawBuffer(GL_BACK);
}

- (void) activateViewport
{
    IVector2 rtv = { width, height };

    [[[[ NP Graphics ] viewportManager ] currentViewport ] setViewportSize:&rtv ];
}

- (void) deactivateViewport
{
    [[[[ NP Graphics ] viewportManager ] currentViewport ] setToControlSize ];
}

- (void) activate
{
    [ self bindFBO ];
    [ self activateDrawBuffers ];
    [ self activateViewport ];
}

- (void) deactivate
{
    [ self unbindFBO ];
    [ self deactivateDrawBuffers ];
    [ self deactivateViewport ];
}

- (BOOL) checkFrameBufferCompleteness
{
    NSString * message = @"";
    BOOL ready = NO;

    NpState status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT);
    switch ( status )
    {
        case GL_FRAMEBUFFER_COMPLETE_EXT: { ready = YES; break; }
        case GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT_EXT: { message = @"FBO Attachment error"; break; }
        case GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT_EXT: { message = @"FBO missing attachment"; break; }
        case GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS_EXT: { message = @"FBO wrong dimensions"; break; }
        case GL_FRAMEBUFFER_INCOMPLETE_FORMATS_EXT: { message = @"FBO wrong format"; break; }
        case GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER_EXT: { message = @"FBO draw buffer error"; break; }
        case GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER_EXT: { message = @"FBO read buffer error"; break; }
        case GL_FRAMEBUFFER_UNSUPPORTED_EXT: { message = @"FBO unsupported format"; break; }
    }

    if ( ready == NO )
    {
        NPLOG_ERROR(message);
    }

    return ready;
}

@end
