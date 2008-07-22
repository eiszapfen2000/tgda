#import "NPRenderTexture.h"
#import "NPRenderTargetConfiguration.h"
#import "Graphics/Material/NPTexture.h"
#import "Graphics/npgl.h"

@implementation NPRenderTexture

+ (id) renderTextureWithName:(NSString *)name
                        type:(NPState)type
                  dataFormat:(NPState)dataFormat
                 pixelFormat:(NPState)pixelFormat
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

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    width = height = -1;

    type = NP_NONE;

	pixelFormat = NP_NONE;
    dataFormat = NP_NONE;

    configuration = nil;
    colorBufferIndex = -1;

    ready = NO;

    return self;
}

- (void) dealloc
{
    [ super dealloc ];
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

- (NPState) type
{
    return type;
}

- (void) setType:(NPState)newType
{
    if ( type != newType )
    {
        type = newType;
    }
}

- (NPState) pixelFormat
{
    return pixelFormat;
}

- (void) setPixelFormat:(NPState)newPixelFormat
{
    if ( pixelFormat != newPixelFormat )
    {
        pixelFormat = newPixelFormat;
    }
}

- (NPState) dataFormat
{
    return dataFormat;
}

- (void) setDataFormat:(NPState)newDataFormat
{
    if ( dataFormat != newDataFormat )
    {
        dataFormat = newDataFormat;
    }
}

- (NPTexture *)texture
{
    return texture;
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
    [ texture setMipMapping:NP_TEXTURE_FILTER_MIPMAPPING_INACTIVE ];
    [ texture setTextureMinFilter:NP_TEXTURE_FILTER_NEAREST ];
    [ texture setTextureMagFilter:NP_TEXTURE_FILTER_NEAREST ];
    [ texture setTextureWrapS:NP_TEXTURE_WRAPPING_CLAMP ];
    [ texture setTextureWrapT:NP_TEXTURE_WRAPPING_CLAMP ];
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
