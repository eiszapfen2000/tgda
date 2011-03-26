#import <Foundation/NSError.h>
#import <Foundation/NSException.h>
#import "Core/Utilities/NSError+NPEngine.h"
#import "Graphics/Texture/NPTexture2D.h"
#import "Graphics/NPEngineGraphics.h"
#import "NPRenderTargetConfiguration.h"
#import "NPRenderTexture.h"

@interface NPRenderTexture (Private)

- (void) deleteTexture;
- (void) createTexture;

@end

@implementation NPRenderTexture (Private)

- (void) deleteTexture
{
    SAFE_DESTROY(texture);
    glID = 0;
    ready = NO;
}

- (void) createTexture
{
    [ self deleteTexture ];

    texture = [[ NPTexture2D alloc ] init ];
    [ texture setWidth:width ];
    [ texture setHeight:height ];
    [ texture setPixelFormat:pixelFormat ];
    [ texture setDataFormat:dataFormat ];
    [ texture setTextureFilter:NpTexture2DFilterNearest ];
    [ texture uploadToGLWithoutData ];

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
    width = height = 0;
    pixelFormat = NpImagePixelFormatUnknown;
    dataFormat = NpRenderBufferDataFormatUnknown;
    texture = nil;
    ready = NO;
    rtc = nil;
    colorBufferIndex = INT_MAX;

    return self;
}

- (void) dealloc
{
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
      pixelFormat:(NpTexturePixelFormat)newPixelFormat
       dataFormat:(NpTextureDataFormat)newDataFormat
            error:(NSError **)error
{
    type = newType;
    width = newWidth;
    height = newHeight;
    pixelFormat = newPixelFormat;
    dataFormat = newDataFormat;

    [ self createTexture ];

    return YES;
}

- (void) attachToRenderTargetConfiguration:(NPRenderTargetConfiguration *)configuration
                          colorBufferIndex:(uint32_t)newColorBufferIndex
{
    NSAssert1(configuration != nil, @"%@: Invalid NPRenderTargetConfiguration", name);
    NSAssert2((int32_t)newColorBufferIndex < [[ NPEngineGraphics instance ] numberOfColorAttachments ],
        @"%@: Invalid color buffer index %u", name, newColorBufferIndex);

    rtc = configuration;
    colorBufferIndex = newColorBufferIndex;
    [ rtc setColorTarget:self atIndex:colorBufferIndex ];

    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, [ rtc glID ]);
    GLenum attachment = GL_COLOR_ATTACHMENT0_EXT + colorBufferIndex;
    glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, attachment, GL_TEXTURE_2D, glID, 0);
    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
}

- (void) detach
{
    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, [ rtc glID ]);
    GLenum attachment = GL_COLOR_ATTACHMENT0_EXT + colorBufferIndex;
    glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, attachment, GL_TEXTURE_2D, 0, 0);
    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);

    [ rtc setColorTarget:nil atIndex:colorBufferIndex ];
    rtc = nil;
    colorBufferIndex = INT_MAX;
}

@end

