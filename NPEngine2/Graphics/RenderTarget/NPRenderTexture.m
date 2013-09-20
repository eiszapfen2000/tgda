#import <Foundation/NSData.h>
#import <Foundation/NSError.h>
#import <Foundation/NSException.h>
#import "Core/Utilities/NSError+NPEngine.h"
#import "Graphics/Texture/NPTexture2D.h"
#import "Graphics/NPEngineGraphics.h"
#import "NPRenderTargetConfiguration.h"
#import "NPRenderTexture.h"

@interface NPRenderTexture (Private)

- (void) deleteTexture;
- (void) createTextureWithMipmaps:(BOOL)mipmaps;

@end

@implementation NPRenderTexture (Private)

- (void) deleteTexture
{
    SAFE_DESTROY(texture);
    glID = 0;
    ready = NO;
}

- (void) createTextureWithMipmaps:(BOOL)mipmaps
{
    [ self deleteTexture ];

    NPTexture2D * texture2D = [[ NPTexture2D alloc ] init ];

    [ texture2D generateUsingWidth:width
                            height:height
                       pixelFormat:pixelFormat
                        dataFormat:dataFormat
                           mipmaps:mipmaps
                              data:[ NSData data ]];

    texture = RETAIN(texture2D);
    DESTROY(texture2D);

    glID = [ texture glID ];
    ready = YES;
}

@end

@implementation NPRenderTexture

- (id) init
{
    return [ self initWithName:@"Render Texture" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    glID = 0;
    type = NpRenderTargetUnknown;
    width = height = depth = 0;
    pixelFormat = NpTexturePixelFormatUnknown;
    dataFormat = NpTextureDataFormatUnknown;
    texture = nil;
    rtc = nil;
    colorBufferIndex = INT_MAX;
    ready = NO;

    return self;
}

- (void) dealloc
{
    [ self deleteTexture ];
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
    return depth;
}

- (id < NPPTexture >) texture
{
    return texture;
}

- (BOOL) generate:(NpRenderTargetType)newType
            width:(uint32_t)newWidth
           height:(uint32_t)newHeight
      pixelFormat:(NpTexturePixelFormat)newPixelFormat
       dataFormat:(NpTextureDataFormat)newDataFormat
    mipmapStorage:(BOOL)mipmapStorage
            error:(NSError **)error
{
    type = newType;
    width = newWidth;
    height = newHeight;
    pixelFormat = newPixelFormat;
    dataFormat = newDataFormat;

    [ self createTextureWithMipmaps:mipmapStorage ];

    return YES;
}

- (void) attachToRenderTargetConfiguration:(NPRenderTargetConfiguration *)configuration
                          colorBufferIndex:(uint32_t)newColorBufferIndex
                                   bindFBO:(BOOL)bindFBO
{
    NSAssert1(configuration != nil, @"%@: Invalid NPRenderTargetConfiguration", name);

    rtc = configuration;

    if (bindFBO == YES)
    {
        glBindFramebuffer(GL_FRAMEBUFFER, [ rtc glID ]);
    }

    switch ( type )
    {
        case NpRenderTargetColor:
        {
            NSAssert2((int32_t)newColorBufferIndex < [[ NPEngineGraphics instance ] numberOfColorAttachments ],
                @"%@: Invalid color buffer index %u", name, newColorBufferIndex);

            colorBufferIndex = newColorBufferIndex;
            GLenum attachment = GL_COLOR_ATTACHMENT0 + colorBufferIndex;
            glFramebufferTexture2D(GL_FRAMEBUFFER, attachment,
                GL_TEXTURE_2D, glID, 0);

            break;
        }

        case NpRenderTargetDepth:
        {
            glFramebufferTexture2D(GL_FRAMEBUFFER,
                GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, glID, 0);

            break;
        }

        case NpRenderTargetDepthStencil:
        {
            glFramebufferTexture2D(GL_FRAMEBUFFER,
                GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, glID, 0);

            glFramebufferTexture2D(GL_FRAMEBUFFER,
                GL_STENCIL_ATTACHMENT, GL_TEXTURE_2D, glID, 0);

            break;
        }

        default:
        {
            break;
        }
    }

    if (bindFBO == YES)
    {
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
    }

    if ( colorBufferIndex != INT_MAX )
    {
        [ rtc setColorTarget:self atIndex:colorBufferIndex ];
    }
    else
    {
        [ rtc setDepthStencilTarget:self ];
    }
}

- (void) detach:(BOOL)bindFBO
{
    // remove self pointer from rtc
    if ( colorBufferIndex != INT_MAX )
    {
        [ rtc setColorTarget:nil atIndex:colorBufferIndex ];
    }
    else
    {
        [ rtc setDepthStencilTarget:nil ];
    }

    // bind FBO if desired
    if ( bindFBO == YES )
    {
        glBindFramebuffer(GL_FRAMEBUFFER, [ rtc glID ]);
    }

    switch ( type )
    {
        case NpRenderTargetColor:
        {
            GLenum attachment = GL_COLOR_ATTACHMENT0 + colorBufferIndex;
            glFramebufferTexture2D(GL_FRAMEBUFFER, attachment,
                GL_TEXTURE_2D, 0, 0);

            break;
        }

        case NpRenderTargetDepth:
        {
            glFramebufferTexture2D(GL_FRAMEBUFFER,
                GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, 0, 0);

            break;
        }

        case NpRenderTargetDepthStencil:
        {
            glFramebufferTexture2D(GL_FRAMEBUFFER,
                GL_DEPTH_ATTACHMENT_EXT, GL_TEXTURE_2D, 0, 0);

            glFramebufferTexture2D(GL_FRAMEBUFFER,
                GL_STENCIL_ATTACHMENT, GL_TEXTURE_2D, 0, 0);

            break;
        }

        default:
        {
            break;
        }
    }

    if ( bindFBO == YES )
    {
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
    }

    rtc = nil;
    colorBufferIndex = INT_MAX;
}

@end

