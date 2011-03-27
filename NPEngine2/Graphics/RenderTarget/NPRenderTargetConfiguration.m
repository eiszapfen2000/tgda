#import <Foundation/NSArray.h>
#import <Foundation/NSError.h>
#import <Foundation/NSNull.h>
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
NSString * const NPFBODimensionsErrorString = @"FBO wrong dimensions.";
NSString * const NPFBOFormatsErrorString = @"FBO wrong format.";
NSString * const NPFBODrawBufferErrorString = @"FBO draw buffer error.";
NSString * const NPFBOReadBufferErrorString = @"FBO read buffer error.";
NSString * const NPFBOUnsupportedErrorString = @"FBO unsupported format.";

@interface NPRenderTargetConfiguration (Private)

+ (NSError *) fboError:(GLenum)fboStatus;
- (void) generateGLFBO;
- (void) deleteGLFBO;
- (void) activateDrawBuffers;
- (void) deactivateDrawBuffers;

@end

@implementation NPRenderTargetConfiguration (Private)

+ (NSError *) fboError:(GLenum)fboStatus
{
    NSString * errorString = nil;
    NSInteger errorCode = NPEngineGraphicsFBOError;

    switch ( fboStatus )
    {
        case GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT_EXT:
        {
            errorString = NPFBOAttachmentErrorString;
            break;
        }
        case GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT_EXT:
        {
            errorString = NPFBOMissingAttachmentErrorString;
            break;
        }
        case GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS_EXT:
        {
            errorString = NPFBODimensionsErrorString;
            break;
        }
        case GL_FRAMEBUFFER_INCOMPLETE_FORMATS_EXT:
        {
            errorString = NPFBOFormatsErrorString;
            break;
        }
        case GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER_EXT:
        {
            errorString = NPFBODrawBufferErrorString;
            break;
        }
        case GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER_EXT:
        {
            errorString = NPFBOReadBufferErrorString;
            break;
        }
        case GL_FRAMEBUFFER_UNSUPPORTED_EXT:
        {
            errorString = NPFBOUnsupportedErrorString;
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
    if ( [[ NPEngineGraphics instance ] supportsARBFBO ] == YES )
    {
        glGenFramebuffers(1, &glID);
    }
    else if ( [[ NPEngineGraphics instance ] supportsEXTFBO ] == YES )
    {
        glGenFramebuffersEXT(1, &glID);
    }
    else
    {
        glID = 0;
    }
}

- (void) deleteGLFBO
{
    if ( [[ NPEngineGraphics instance ] supportsARBFBO ] == YES )
    {
        glDeleteFramebuffers(1, &glID);
    }
    else if ( [[ NPEngineGraphics instance ] supportsEXTFBO ] == YES )
    {
        glDeleteFramebuffersEXT(1, &glID);
    }
    else
    {
        glID = 0;
    }
}

- (void) activateDrawBuffers
{
    int32_t numberOfColorAttachments
        = [[ NPEngineGraphics instance ] numberOfColorAttachments ];

    GLenum buffers[numberOfColorAttachments];
    GLsizei bufferCount = 0;

    for ( int32_t i = 0; i < numberOfColorAttachments; i++ )
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
    depthStencil = nil;

    int32_t numberOfColorAttachments
        = [[ NPEngineGraphics  instance ] numberOfColorAttachments ];

    colorTargets
        = [[ NSMutableArray alloc ] 
                initWithCapacity:(NSUInteger)numberOfColorAttachments ];

    for ( int32_t i = 0; i < numberOfColorAttachments; i++ )
    {
        [ colorTargets addObject:[ NSNull null ]];
    }

    return self;
}

- (void) dealloc
{
    [ colorTargets removeAllObjects ];
    DESTROY(colorTargets);
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


- (void) setColorTarget:(NPRenderTexture *)colorTarget
                atIndex:(uint32_t)index
{
    if ( [ colorTargets objectAtIndex:index ] != [ NSNull null ] )
    {
        [ colorTargets replaceObjectAtIndex:index withObject:[ NSNull null ]];
    }

    if ( colorTarget != nil )
    {
        [ colorTargets replaceObjectAtIndex:index withObject:colorTarget ];
    }
}

- (void) setDepthStencilTarget:(NPRenderBuffer *)depthStencilTarget
{
    if ( depthStencil != nil )
    {
        DESTROY(depthStencil);
    }

    if ( depthStencilTarget != nil )
    {
        depthStencil = RETAIN(depthStencilTarget);
    }
}


- (BOOL) checkFrameBufferCompleteness:(NSError **)error
{
    BOOL result = YES;
    GLenum status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT);

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

- (void) activate
{
    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, glID);

    [ self activateDrawBuffers ];
    [[[ NPEngineGraphics instance ] viewport ] setWidth:width height:height ];    
}

- (void) deactivate
{
    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);

    [ self deactivateDrawBuffers ];
    [[[ NPEngineGraphics instance ] viewport ] reset ];
}

@end

