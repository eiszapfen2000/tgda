#import <Foundation/NSData.h>
#import <Foundation/NSError.h>
#import <Foundation/NSException.h>
#import "Core/Utilities/NSError+NPEngine.h"
#import "Graphics/Texture/NPTexture2D.h"
#import "Graphics/Texture/NPTexture3D.h"
#import "Graphics/NPEngineGraphics.h"
#import "NPRenderTargetConfiguration.h"
#import "NPRenderTexture.h"

@interface NPRenderTexture (Private)

- (void) deleteTexture;
- (void) createTextureWithMipmaps:(BOOL)mipmaps;
- (void) createTexture3DWithMipmaps:(BOOL)mipmaps;

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

- (void) createTexture3DWithMipmaps:(BOOL)mipmaps
{
    [ self deleteTexture ];

    NPTexture3D * texture3D = [[ NPTexture3D alloc ] init ];

    [ texture3D generateUsingWidth:width
                            height:height
                             depth:depth
                       pixelFormat:pixelFormat
                        dataFormat:dataFormat
                           mipmaps:mipmaps
                              data:[ NSData data ]];

    texture = RETAIN(texture3D);
    DESTROY(texture3D);

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
    type   = newType;
    width  = newWidth;
    height = newHeight;
    depth  = 0;
    pixelFormat = newPixelFormat;
    dataFormat  = newDataFormat;

    [ self createTextureWithMipmaps:mipmapStorage ];

    return YES;
}

- (BOOL) generate3D:(NpRenderTargetType)newType
              width:(uint32_t)newWidth
             height:(uint32_t)newHeight
              depth:(uint32_t)newDepth
        pixelFormat:(NpTexturePixelFormat)newPixelFormat
         dataFormat:(NpTextureDataFormat)newDataFormat
      mipmapStorage:(BOOL)mipmapStorage
              error:(NSError **)error
{
    type   = newType;
    width  = newWidth;
    height = newHeight;
    depth  = newDepth;
    pixelFormat = newPixelFormat;
    dataFormat  = newDataFormat;

    [ self createTexture3DWithMipmaps:mipmapStorage ];

    return YES;
}

- (void) attachToRenderTargetConfiguration:(NPRenderTargetConfiguration *)configuration
                          colorBufferIndex:(uint32_t)newColorBufferIndex
                                   bindFBO:(BOOL)bindFBO
{
            [ self attachLevel:0
     renderTargetConfiguration:configuration
              colorBufferIndex:newColorBufferIndex
                       bindFBO:bindFBO ];
}

- (void)       attachLevel:(uint32_t)newLevel
 renderTargetConfiguration:(NPRenderTargetConfiguration *)configuration
          colorBufferIndex:(uint32_t)newColorBufferIndex
                   bindFBO:(BOOL)bindFBO
{
    NSAssert([ texture isKindOfClass:[ NPTexture2D class ]] == YES, @"Render texture is not a 2D texture");
    NSAssert1(configuration != nil, @"%@: Invalid NPRenderTargetConfiguration", name);
    NSAssert2((int32_t)newColorBufferIndex < [[ NPEngineGraphics instance ] numberOfColorAttachments ],
        @"%@: Invalid color buffer index %u", name, newColorBufferIndex);

    rtc = configuration;

    if (bindFBO == YES)
    {
        glBindFramebuffer(GL_FRAMEBUFFER, [ rtc glID ]);
    }

    colorBufferIndex = newColorBufferIndex;
    GLenum attachment = getGLAttachment(type, colorBufferIndex);

    NSAssert(attachment != GL_NONE, @"");
    glFramebufferTexture2D(GL_FRAMEBUFFER, attachment, GL_TEXTURE_2D, glID, newLevel);

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

- (void)       attachLevel:(uint32_t)newLevel
                     layer:(uint32_t)newLayer
 renderTargetConfiguration:(NPRenderTargetConfiguration *)configuration
          colorBufferIndex:(uint32_t)newColorBufferIndex
                   bindFBO:(BOOL)bindFBO
{
    /*
    switch ( type )
    {
        case NpRenderTargetColor:
        {
            NSAssert2((int32_t)newColorBufferIndex < [[ NPEngineGraphics instance ] numberOfColorAttachments ],
                @"%@: Invalid color buffer index %u", name, newColorBufferIndex);

            colorBufferIndex = newColorBufferIndex;
            GLenum attachment = GL_COLOR_ATTACHMENT0 + colorBufferIndex;
            glFramebufferTexture3D(GL_FRAMEBUFFER, attachment,
                GL_TEXTURE_3D, glID, newLevel, newLayer);

            break;
        }

        case NpRenderTargetDepth:
        {
            glFramebufferTexture3D(GL_FRAMEBUFFER,
                GL_DEPTH_ATTACHMENT, GL_TEXTURE_3D, glID, newLevel, newLayer);

            break;
        }

        case NpRenderTargetDepthStencil:
        {
            glFramebufferTexture3D(GL_FRAMEBUFFER,
                GL_DEPTH_ATTACHMENT, GL_TEXTURE_3D, glID, newLevel, newLayer);

            glFramebufferTexture3D(GL_FRAMEBUFFER,
                GL_STENCIL_ATTACHMENT, GL_TEXTURE_3D, glID, newLevel, newLayer);

            break;
        }

        default:
        {
            break;
        }
    }
    */
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
            glFramebufferTexture(GL_FRAMEBUFFER, attachment, 0, 0);

            break;
        }

        case NpRenderTargetDepth:
        {
            glFramebufferTexture(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, 0, 0);

            break;
        }

        case NpRenderTargetDepthStencil:
        {
            glFramebufferTexture(GL_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, 0, 0);

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

