#import "NPRenderBuffer.h"
#import "NPRenderTargetConfiguration.h"
#import "Graphics/npgl.h"
#import "NP.h"

@implementation NPRenderBuffer

+ (id) renderBufferWithName:(NSString *)name type:(NpState)type format:(NpState)format width:(Int)width height:(Int)height
{
    NPRenderBuffer * renderBuffer = [[ NPRenderBuffer alloc ] initWithName:name ];
    [ renderBuffer setType:type ];
    [ renderBuffer setFormat:format ];
    [ renderBuffer setWidth:width ];
    [ renderBuffer setHeight:height ];
    [ renderBuffer uploadToGL ];

    return [ renderBuffer autorelease ];
}

- (id) init
{
    return [ self initWithName:@"NPRenderBuffer" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

	[ self generateGLRenderBufferID ];

    width = height = -1;

    type = NP_NONE;
	format = NP_NONE;

    configuration = nil;

    return self;
}

- (void) dealloc
{
    [ super dealloc ];
}

- (void) generateGLRenderBufferID
{
	glGenRenderbuffersEXT(1, &renderBufferID);
}

- (Int) width
{
    return width;
}

- (void) setWidth:(Int)newWidth
{
    if ( width != newWidth )
    {
        width = newWidth;
    }
}

- (Int) height
{
    return height;
}

- (void) setHeight:(Int)newHeight
{
    if ( height != newHeight )
    {
        height = newHeight;
    }
}

- (NpState) type
{
    return type;
}

- (void) setType:(NpState)newType
{
    if ( type != newType )
    {
        type = newType;
    }
}

- (NpState) format
{
	return format;
}

- (void) setFormat:(NpState)newFormat
{
	if ( format != newFormat )
	{
		format = newFormat;
	}
}

- (GLenum) computeInternalFormat
{
    GLenum internalFormat;
    switch ( type )
    {
        case NP_RENDERBUFFER_DEPTH_TYPE:
        {
            switch(format)
            {
	            case NP_RENDERBUFFER_DEPTH16:{internalFormat = GL_DEPTH_COMPONENT16; break;}
	            case NP_RENDERBUFFER_DEPTH24:{internalFormat = GL_DEPTH_COMPONENT24; break;}
	            case NP_RENDERBUFFER_DEPTH32:{internalFormat = GL_DEPTH_COMPONENT32; break;}
                default                     :{NPLOG_ERROR(@"RenderBuffer: Unknown depth format"); break;}
            }
        }
        break;

        case NP_RENDERBUFFER_STENCIL_TYPE:
        {
            switch(format)
            {
	            case NP_RENDERBUFFER_STENCIL1 :{internalFormat = GL_STENCIL_INDEX1_EXT; break;}
	            case NP_RENDERBUFFER_STENCIL4 :{internalFormat = GL_STENCIL_INDEX4_EXT; break;}
	            case NP_RENDERBUFFER_STENCIL8 :{internalFormat = GL_STENCIL_INDEX8_EXT; break;}
	            case NP_RENDERBUFFER_STENCIL16:{internalFormat = GL_STENCIL_INDEX16_EXT; break;}
                default                       :{NPLOG_ERROR(@"RenderBuffer: Unknown stencil format"); break;}
            }
        }
        break;

        case NP_RENDERBUFFER_DEPTH_STENCIL_TYPE:
        {
            switch(format)
            {
	            case NP_RENDERBUFFER_DEPTH24_STENCIL8:{internalFormat = GL_DEPTH24_STENCIL8_EXT; break;}
                default                              :{NPLOG_ERROR(@"RenderBuffer: Unknown depth-stencil format"); break;}
            }
        }
        break;

        default:{NPLOG_ERROR(@"RenderBuffer: Unknown type"); break;}
    }

    return internalFormat;
}

- (void) uploadToGL
{
    glBindRenderbufferEXT(GL_RENDERBUFFER_EXT, renderBufferID);

    GLenum internalFormat = [ self computeInternalFormat ];

    glRenderbufferStorageEXT(GL_RENDERBUFFER_EXT, internalFormat, width, height);
    glBindRenderbufferEXT(GL_RENDERBUFFER_EXT, 0);
}

- (GLenum) computeAttachment
{
    GLenum attachment;
    switch ( type )
    {
        case NP_RENDERBUFFER_DEPTH_TYPE  :{attachment = GL_DEPTH_ATTACHMENT_EXT; break;}
        case NP_RENDERBUFFER_STENCIL_TYPE:{attachment = GL_STENCIL_ATTACHMENT_EXT; break;}
        default                          :{NPLOG_ERROR(@"RenderBuffer: Unknow attachment"); break;}
    }

    return attachment;
}

- (void) bindToRenderTargetConfiguration:(NPRenderTargetConfiguration *)newConfiguration
{
    if ( configuration != newConfiguration )
    {
        [ configuration release ];
        configuration = [ newConfiguration retain ];

        glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, [ configuration fboID ]);

        if ( type == NP_RENDERBUFFER_DEPTH_STENCIL_TYPE )
        {
            glFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT, GL_DEPTH_ATTACHMENT_EXT, GL_RENDERBUFFER_EXT, renderBufferID);
            glFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT, GL_STENCIL_ATTACHMENT_EXT, GL_RENDERBUFFER_EXT, renderBufferID);
        }
        else
        {
            GLenum attachment = [ self computeAttachment ];
            glFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT, attachment, GL_RENDERBUFFER_EXT, renderBufferID);
        }

        glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
    }    
}

- (void) unbindFromRenderTargetConfiguration
{
    if ( configuration != nil )
    {
        glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, [ configuration fboID ]);

        if ( type == NP_RENDERBUFFER_DEPTH_STENCIL_TYPE )
        {
            glFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT, GL_DEPTH_ATTACHMENT_EXT, GL_RENDERBUFFER_EXT, 0);
            glFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT, GL_STENCIL_ATTACHMENT_EXT, GL_RENDERBUFFER_EXT, 0);
        }
        else
        {
            GLenum attachment = [ self computeAttachment ];
            glFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT, attachment, GL_RENDERBUFFER_EXT, 0);
        }

        glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);

        [ configuration release ];
        configuration = nil;
    }
}

@end
