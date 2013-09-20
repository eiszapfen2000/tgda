#import <Foundation/NSArray.h>
#import <Foundation/NSError.h>
#import <Foundation/NSNull.h>
#import <Foundation/NSPointerArray.h>
#import "GL/glew.h"
#import "Core/Utilities/NSError+NPEngine.h"
#import "Graphics/NPEngineGraphics.h"
#import "Graphics/NPEngineGraphicsErrors.h"
#import "Graphics/NPViewport.h"
#import "NPRenderBuffer.h"
#import "NPRenderTexture.h"
#import "NPRenderTargetConfiguration.h"

NSString * const NPFBOAttachmentErrorString = @"FBO Attachment error.";
NSString * const NPFBOMissingAttachmentErrorString = @"FBO missing attachment.";
NSString * const NPFBODrawBufferErrorString = @"FBO draw buffer error.";
NSString * const NPFBOReadBufferErrorString = @"FBO read buffer error.";
NSString * const NPFBOUnsupportedErrorString = @"FBO unsupported format.";
NSString * const NPFBOMultiSampleErrorString = @"FBO attachments multisample settings mismatch.";
NSString * const NPFBOLayerErrorString = @"FBO attachments layer mismatch.";

@interface NPRenderTargetConfiguration (Private)

+ (NSError *) fboError:(GLenum)fboStatus;
- (void) generateGLFBO;
- (void) deleteGLFBO;

@end

@implementation NPRenderTargetConfiguration (Private)

+ (NSError *) fboError:(GLenum)fboStatus
{
    NSString * errorString = nil;
    NSInteger errorCode = NPEngineGraphicsFBOError;

    switch ( fboStatus )
    {
        case GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT:
        {
            errorString = NPFBOAttachmentErrorString;
            break;
        }
        case GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT:
        {
            errorString = NPFBOMissingAttachmentErrorString;
            break;
        }
        case GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER:
        {
            errorString = NPFBODrawBufferErrorString;
            break;
        }
        case GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER:
        {
            errorString = NPFBOReadBufferErrorString;
            break;
        }
        case GL_FRAMEBUFFER_UNSUPPORTED:
        {
            errorString = NPFBOUnsupportedErrorString;
            break;
        }
        case GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE:
        {
            errorString = NPFBOMultiSampleErrorString;
            break;
        }
        case GL_FRAMEBUFFER_INCOMPLETE_LAYER_TARGETS:
        {
            errorString = NPFBOLayerErrorString;
            break;
        }
        default:
        {
            break;
        }
    }

    return [ NSError errorWithCode:errorCode description:errorString ];
}

- (void) generateGLFBO
{
    glGenFramebuffers(1, &glID);
}

- (void) deleteGLFBO
{
    glDeleteFramebuffers(1, &glID);
}

@end

@implementation NPRenderTargetConfiguration

- (id) init
{
    return [ self initWithName:@"NPRenderTargetConfiguration" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

	[ self generateGLFBO ];

	width = height = 0;

    int32_t numberOfColorAttachments
        = [[ NPEngineGraphics instance ] numberOfColorAttachments ];

    NSPointerFunctionsOptions options
        = NSPointerFunctionsObjectPointerPersonality | NSPointerFunctionsStrongMemory;

    targets = [[ NSPointerArray alloc ] initWithOptions:options ];

    // last target is depth / depthstencil
    [ targets setCount:(numberOfColorAttachments + 1) ];

    return self;
}

- (void) dealloc
{
    [ targets setCount:0 ];
    DESTROY(targets);
    [ self deleteGLFBO ];

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

- (void) setWidth:(uint32_t)newWidth
{
    width = newWidth;
}

- (void) setHeight:(uint32_t)newHeight
{
    height = newHeight;
}

- (void) bindFBO
{
    glBindFramebuffer(GL_FRAMEBUFFER, glID);
}

- (void) unbindFBO
{
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

- (void) setColorTarget:(id < NPPRenderTarget2D >)colorTarget
                atIndex:(uint32_t)index
{
    [ targets replacePointerAtIndex:index withPointer:colorTarget ];
}

- (void) setDepthStencilTarget:(id < NPPRenderTarget2D >)depthStencilTarget
{
    int32_t numberOfColorAttachments
        = [[ NPEngineGraphics instance ] numberOfColorAttachments ];

    [ targets
        replacePointerAtIndex:numberOfColorAttachments
                  withPointer:depthStencilTarget ];
}

- (BOOL) checkFrameBufferCompleteness:(NSError **)error
{
    BOOL result = YES;
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);

    if ( status != GL_FRAMEBUFFER_COMPLETE_EXT )
    {
        result = NO;

        if ( error != NULL )
        {
            *error = [ NPRenderTargetConfiguration fboError:status ];
        }
    }

    return result;
}

- (void) activateDrawBuffers
{
    int32_t numberOfColorAttachments
        = [[ NPEngineGraphics instance ] numberOfColorAttachments ];

    GLenum buffers[numberOfColorAttachments];
    GLsizei bufferCount = 0;

    for ( int32_t i = 0; i < numberOfColorAttachments; i++ )
    {
        if ( [ targets pointerAtIndex:i ] != nil )
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
    [[[ NPEngineGraphics instance ] viewport ] setWidth:width height:height ]; 
}

- (void) deactivateViewport
{
    [[[ NPEngineGraphics instance ] viewport ] reset ];
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

@end

