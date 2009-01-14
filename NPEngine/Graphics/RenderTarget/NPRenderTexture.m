#import "NPRenderTexture.h"
#import "NPRenderTargetConfiguration.h"
#import "Graphics/Material/NPTexture.h"
#import "Graphics/npgl.h"
#import "Graphics/NPEngineGraphicsConstants.h"

@implementation NPRenderTexture

+ (id) renderTextureWithName:(NSString *)name
                        type:(NpState)type
                  dataFormat:(NpState)dataFormat
                 pixelFormat:(NpState)pixelFormat
                       width:(Int)width
                      height:(Int)height;
{
    NPRenderTexture * renderTexture = [[ NPRenderTexture alloc ] initWithName:name ];
    [ renderTexture setType:type ];
    [ renderTexture setDataFormat:dataFormat ];
    [ renderTexture setPixelFormat:pixelFormat ];
    [ renderTexture setWidth:width ];
    [ renderTexture setHeight:height ];
    [ renderTexture createTexture ];

    return [ renderTexture autorelease ];
}

- (id) init
{
    return [ self initWithName:@"NPRenderTexture" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    type = NP_NONE;
	pixelFormat = NP_NONE;
    dataFormat = NP_NONE;
    width = height = -1;

    configuration = nil;
    colorBufferIndex = -1;

    ready = NO;

    return self;
}

- (void) dealloc
{
    [ texture reset ];
    [ texture release ];

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

- (NpState) type
{
    return type;
}

- (NpState) pixelFormat
{
    return pixelFormat;
}

- (NpState) dataFormat
{
    return dataFormat;
}

- (void) setWidth:(Int)newWidth
{
    width = newWidth;
}

- (NPTexture *)texture
{
    return texture;
}

- (UInt) colorBufferIndex
{
    return [ configuration colorBufferIndexForRenderTexture:self ];
}

- (void) setHeight:(Int)newHeight
{
    height = newHeight;
}

- (void) setType:(NpState)newType
{
    type = newType;
}

- (void) setPixelFormat:(NpState)newPixelFormat
{
    pixelFormat = newPixelFormat;
}

- (void) setDataFormat:(NpState)newDataFormat
{
    dataFormat = newDataFormat;
}

- (void) createTexture
{
    if ( texture != nil )
    {
        [ texture reset ];
        [ texture release ];
    }

    texture = [[ NPTexture alloc ] initWithName:@"RenderTexture" parent:self ];
    [ texture generateGLTextureID ];
    [ texture setWidth:width ];
    [ texture setHeight:height ];
    [ texture setDataFormat:dataFormat ];
    [ texture setPixelFormat:pixelFormat ];
    [ texture setMipMapping:NP_GRAPHICS_TEXTURE_FILTER_MIPMAPPING_INACTIVE ];
    [ texture setTextureMinFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST ];
    [ texture setTextureMagFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST ];
    [ texture setTextureWrapS:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP ];
    [ texture setTextureWrapT:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP ];
    [ texture uploadToGLWithoutImageData ];

    renderTextureID = [ texture textureID ];
}

- (void) bindToRenderTargetConfiguration:(NPRenderTargetConfiguration *)newConfiguration colorBufferIndex:(Int)newColorBufferIndex
{
    if ( configuration != newConfiguration )
    {
        TEST_RELEASE(configuration);
        configuration = [ newConfiguration retain ];

        glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, [ configuration fboID ]);

        colorBufferIndex = newColorBufferIndex;
        GLenum attachment = GL_COLOR_ATTACHMENT0_EXT + colorBufferIndex;
        glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, attachment, GL_TEXTURE_2D, renderTextureID, 0);

        glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
    }
}

- (void) unbindFromRenderTargetConfiguration
{
    if ( configuration != nil )
    {
        glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, [ configuration fboID ]);

        GLenum attachment = GL_COLOR_ATTACHMENT0_EXT + colorBufferIndex;
        glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, attachment, GL_TEXTURE_2D, 0, 0);

        glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);

        [ configuration release ];
        configuration = nil;
    }
}

@end
