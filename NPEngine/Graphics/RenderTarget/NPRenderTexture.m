#import "NPRenderTexture.h"
#import "NPRenderTargetConfiguration.h"
#import "Graphics/Material/NPTexture.h"
#import "Graphics/Image/NPImage.h"
#import "Graphics/npgl.h"
#import "Graphics/NPEngineGraphicsConstants.h"

@implementation NPRenderTexture

+ (id) renderTextureWithName:(NSString *)name
                        type:(NpState)type
                       width:(Int)width
                      height:(Int)height
                  dataFormat:(NpState)dataFormat
                 pixelFormat:(NpState)pixelFormat
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

+ (id) renderTextureWithName:(NSString *)name
                        type:(NpState)type
                       width:(Int)width
                      height:(Int)height
                  dataFormat:(NpState)dataFormat
                 pixelFormat:(NpState)pixelFormat
               textureFilter:(NpState)textureFilter
                 textureWrap:(NpState)textureWrap
{
    #warning FIXME Handle mipmaps

    NPRenderTexture * renderTexture = [[ NPRenderTexture alloc ] initWithName:name ];
    [ renderTexture setType:type ];
    [ renderTexture setDataFormat:dataFormat ];
    [ renderTexture setPixelFormat:pixelFormat ];
    [ renderTexture setWidth:width ];
    [ renderTexture setHeight:height ];

    [ renderTexture createTextureWithTextureFilter:textureFilter
                                       textureWrap:textureWrap ];

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
    if ( configuration != nil )
    {
        [ configuration release ];
    }

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

- (UInt) renderTextureID
{
    return renderTextureID;
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

- (void) createTextureWithTextureFilter:(NpState)textureFilter
                            textureWrap:(NpState)textureWrap
{
    if ( texture != nil )
    {
        [ texture reset ];
        [ texture release ];
    }

    texture = [[ NPTexture alloc ] initWithName:@"RenderTexture" parent:self ];
    [ texture setWidth:width ];
    [ texture setHeight:height ];
    [ texture setDataFormat:dataFormat ];
    [ texture setPixelFormat:pixelFormat ];
    [ texture setTextureFilter:textureFilter ];
    [ texture setTextureWrap:textureWrap ];

    [ texture uploadToGLWithoutData ];

    renderTextureID = [ texture textureID ];
}

- (void) createTexture
{
    [ self createTextureWithTextureFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST
                              textureWrap:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP ];
}

- (void) attachToColorBufferIndex:(Int)newColorBufferIndex
{
        colorBufferIndex = newColorBufferIndex;
        GLenum attachment = GL_COLOR_ATTACHMENT0_EXT + colorBufferIndex;
        glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, attachment, GL_TEXTURE_2D, renderTextureID, 0);
}

- (void) detach
{
        GLenum attachment = GL_COLOR_ATTACHMENT0_EXT + colorBufferIndex;
        glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, attachment, GL_TEXTURE_2D, 0, 0);
}

- (void) bindToRenderTargetConfiguration:(NPRenderTargetConfiguration *)newConfiguration
                        colorBufferIndex:(Int)newColorBufferIndex
{
    if ( configuration != newConfiguration )
    {
        TEST_RELEASE(configuration);
        configuration = [ newConfiguration retain ];

        [ configuration bindFBO ];
        [ self attachToColorBufferIndex:newColorBufferIndex ];
        [ configuration unbindFBO ];
    }
}

- (void) unbindFromRenderTargetConfiguration
{
    if ( configuration != nil )
    {
        [ configuration bindFBO ];
        [ self detach ];
        [ configuration unbindFBO ];

        [ configuration release ];
        configuration = nil;
    }
}

@end
