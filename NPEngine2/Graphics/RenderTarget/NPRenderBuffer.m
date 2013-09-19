#import <Foundation/NSError.h>
#import <Foundation/NSException.h>
#import "Core/Utilities/NSError+NPEngine.h"
#import "Graphics/NPEngineGraphics.h"
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

- (id) init
{
    return [ self initWithName:@"Render Buffer" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    glID = 0;
    type = NpRenderTargetUnknown;
    width = height = 0;
    pixelFormat = NpTexturePixelFormatUnknown;
    dataFormat = NpTextureDataFormatUnknown;
    rtc = nil;
    colorBufferIndex = INT_MAX;
    ready = NO;

    return self;
}

- (void) dealloc
{
    [ self deleteGLRenderBuffer ];
    [ super dealloc ];
}

- (GLuint) glID
{
    return glID;
}

- (uint32_t) width
{
    return width;
}

- (uint32_t) height
{
    return height;
}

- (uint32_t) depth
{
    return 0;
}

- (BOOL) generate:(NpRenderTargetType)newType
            width:(uint32_t)newWidth
           height:(uint32_t)newHeight
      pixelFormat:(NpTexturePixelFormat)newPixelFormat
       dataFormat:(NpTextureDataFormat)newDataFormat
            error:(NSError **)error
{
    [ self deleteGLRenderBuffer ];

    glGenRenderbuffersEXT(1, &glID);
    if ( glID == 0 )
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
        = getGLTextureInternalFormat(dataFormat, pixelFormat, false,
                                     NULL, NULL);

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
                          colorBufferIndex:(uint32_t)newColorBufferIndex
                                   bindFBO:(BOOL)bindFBO
{
    NSAssert1(configuration != nil, @"%@: Invalid NPRenderTargetConfiguration", name);

    rtc = configuration;

    if ( bindFBO == YES )
    {
        glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, [ rtc glID ]);
    }

    switch ( type )
    {
        case NpRenderTargetColor:
        {
            NSAssert2((int32_t)newColorBufferIndex < [[ NPEngineGraphics instance ] numberOfColorAttachments ],
                @"%@: Invalid color buffer index %u", name, newColorBufferIndex);


            colorBufferIndex = newColorBufferIndex;
            GLenum attachment = GL_COLOR_ATTACHMENT0_EXT + colorBufferIndex;

            glFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT,attachment,
                GL_RENDERBUFFER_EXT, glID);

            break;
        }

        case NpRenderTargetDepth:
        {
            glFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT,
                GL_DEPTH_ATTACHMENT_EXT, GL_RENDERBUFFER_EXT, glID);

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

    if ( bindFBO == YES )
    {
        glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
    }

    if ( colorBufferIndex == INT_MAX )
    {
        [ rtc setDepthStencilTarget:self ];
    }
    else
    {
        [ rtc setColorTarget:self atIndex:colorBufferIndex ];
    }
}

- (void) detach:(BOOL)bindFBO
{
    // remove self pointer from rtc
    if ( colorBufferIndex == INT_MAX )
    {
        [ rtc setDepthStencilTarget:nil ];
    }
    else
    {
        [ rtc setColorTarget:nil atIndex:colorBufferIndex ];
    }

    if ( bindFBO == YES )
    {
        glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, [ rtc glID ]);
    }

    switch ( type )
    {
        case NpRenderTargetColor:
        {
            GLenum attachment = GL_COLOR_ATTACHMENT0_EXT + colorBufferIndex;
            glFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT, attachment,
                GL_RENDERBUFFER_EXT, 0);

            break;
        }

        case NpRenderTargetDepth:
        {
            glFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT,
                GL_DEPTH_ATTACHMENT_EXT, GL_RENDERBUFFER_EXT, 0);

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

    if ( bindFBO == YES )
    {
        glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
    }

    rtc = nil;
    colorBufferIndex = INT_MAX;
}

@end


