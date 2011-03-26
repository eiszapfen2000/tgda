#import <Foundation/NSError.h>
#import <Foundation/NSException.h>
#import "Core/Utilities/NSError+NPEngine.h"
#import "NPRenderTargetConfiguration.h"
#import "NPRenderBuffer.h"

@interface NPRenderBuffer (Private)

- (void) deleteGLRenderBuffer;

@end

@implementation NPRenderBuffer (Private)

- (void) deleteGLRenderBuffer
{
	if ( glID > 0 )
	{
		glDeleteRenderbuffersEXT(1, &glID);
        glID = 0;
        ready = NO;
	}
}

@end

@implementation NPRenderBuffer

- (id) init;
{
    return [ self initWithName:@"Render Buffer" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    glID = 0;
    type = NpRenderTargetUnknown;
    width = height = 0;
    pixelFormat = NpImagePixelFormatUnknown;
    dataFormat = NpRenderBufferDataFormatUnknown;
    ready = NO;
    rtc = nil;

    return self;
}

- (void) dealloc
{
    [ self deleteGLRenderBuffer ];
    [ super dealloc ];
}

- (uint32_t) width
{
    return width;
}

- (uint32_t) height
{
    return height;
}

- (BOOL) generate:(NpRenderTargetType)newType
            width:(uint32_t)newWidth
           height:(uint32_t)newHeight
      pixelFormat:(NpImagePixelFormat)newPixelFormat
       dataFormat:(NpRenderBufferDataFormat)newDataFormat
            error:(NSError **)error
{
    [ self deleteGLRenderBuffer ];

    glGenRenderbuffersEXT(1, &glID);

    if ( glID <= 0 )
    {
        // log error
        return NO;
    }

    type = newType;
    width = newWidth;
    height = newHeight;
    pixelFormat = newPixelFormat;
    dataFormat = newDataFormat;

    GLenum internalFormat
        = getGLRenderBufferInternalFormat(type, pixelFormat, dataFormat);

    glBindRenderbufferEXT(GL_RENDERBUFFER_EXT, glID);
    glRenderbufferStorageEXT(GL_RENDERBUFFER_EXT, internalFormat, width, height);

    if ( glIsRenderbufferEXT(glID) == GL_FALSE )
    {
        // log error
        return NO;
    }

    glBindRenderbufferEXT(GL_RENDERBUFFER_EXT, 0);
    ready = YES;

    return YES;
}

- (void) attachToRenderTargetConfiguration:(NPRenderTargetConfiguration *)configuration
{
    NSAssert1(configuration != nil, @"%@: Invalid NPRenderTargetConfiguration", name);

    rtc = configuration;
    [ rtc setDepthStencilTarget:self ];

    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, [ rtc glID ]);

    switch ( type )
    {
        case NpRenderTargetDepth:
        {
            glFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT,
                GL_DEPTH_ATTACHMENT_EXT, GL_RENDERBUFFER_EXT, glID);

            break;
        }

        case NpRenderTargetStencil:
        {
            glFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT,
                GL_STENCIL_ATTACHMENT_EXT, GL_RENDERBUFFER_EXT, glID);

            break;
        }

        case NpRenderTargetDepthStencil:
        {
            glFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT,
                GL_DEPTH_ATTACHMENT_EXT, GL_RENDERBUFFER_EXT, glID);

            glFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT,
                GL_STENCIL_ATTACHMENT_EXT, GL_RENDERBUFFER_EXT, glID);

            break;
        }

        default:
        {
            break;
        }
    }

    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
}

- (void) detach
{
    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, [ rtc glID ]);

    switch ( type )
    {
        case NpRenderTargetDepth:
        {
            glFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT,
                GL_DEPTH_ATTACHMENT_EXT, GL_RENDERBUFFER_EXT, 0);

            break;
        }

        case NpRenderTargetStencil:
        {
            glFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT,
                GL_STENCIL_ATTACHMENT_EXT, GL_RENDERBUFFER_EXT, 0);

            break;
        }

        case NpRenderTargetDepthStencil:
        {
            glFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT,
                GL_DEPTH_ATTACHMENT_EXT, GL_RENDERBUFFER_EXT, 0);

            glFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT,
                GL_STENCIL_ATTACHMENT_EXT, GL_RENDERBUFFER_EXT, 0);

            break;
        }

        default:
        {
            break;
        }
    }

    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);

    [ rtc setDepthStencilTarget:nil ];
    rtc = nil;
}

@end


