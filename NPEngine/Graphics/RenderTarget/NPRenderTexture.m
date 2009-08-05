#import "NPRenderTexture.h"
#import "NP.h"

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
    [ texture setTextureWrap:textureWrap ];

    [ texture uploadToGLWithoutData ];

    NpTextureFilterState * textureFilterState = [ texture textureFilterState ];

    switch ( textureFilter )
    {
        case NP_GRAPHICS_TEXTURE_FILTER_LINEAR_MIPMAPPING:
        {
            textureFilterState->minFilter  = NP_GRAPHICS_TEXTURE_FILTER_LINEAR_MIPMAP_NEAREST;
            textureFilterState->magFilter  = NP_GRAPHICS_TEXTURE_FILTER_NEAREST;

            glBindTexture(GL_TEXTURE_2D, [ texture textureID ]);
            glGenerateMipmapEXT(GL_TEXTURE_2D);
            glBindTexture(GL_TEXTURE_2D, 0);

            break;
        }

        case NP_GRAPHICS_TEXTURE_FILTER_TRILINEAR:
        {
            textureFilterState->minFilter = NP_GRAPHICS_TEXTURE_FILTER_LINEAR_MIPMAP_LINEAR;
            textureFilterState->magFilter = NP_GRAPHICS_TEXTURE_FILTER_LINEAR;

            glBindTexture(GL_TEXTURE_2D, [ texture textureID ]);
            glGenerateMipmapEXT(GL_TEXTURE_2D);
            glBindTexture(GL_TEXTURE_2D, 0);

            break;
        }

        default:
        {
            [ texture setTextureFilter:textureFilter ];
            break;
        }
    }

    renderTextureID = [ texture textureID ];
}

- (void) createTexture
{
    [ self createTextureWithTextureFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST
                              textureWrap:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP ];
}

- (void) generateMipMaps
{
    if ( configuration != [[[ NP Graphics ] renderTargetManager ] currentRenderTargetConfiguration ] )
    {
        #warning FIXME Possible clash with 3D texture mode
        glBindTexture(GL_TEXTURE_2D, renderTextureID);
        glGenerateMipmapEXT(GL_TEXTURE_2D);
        glBindTexture(GL_TEXTURE_2D, 0);
    }
}

- (void) attachToColorBufferIndex:(Int)newColorBufferIndex
{
    ASSIGN(configuration, [[[ NP Graphics ] renderTargetManager ] currentRenderTargetConfiguration ]);

    [[ configuration colorTargets ] replaceObjectAtIndex:newColorBufferIndex withObject:self ];

    colorBufferIndex = newColorBufferIndex;
    GLenum attachment = GL_COLOR_ATTACHMENT0_EXT + colorBufferIndex;
    glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, attachment, GL_TEXTURE_2D, renderTextureID, 0);
}

- (void) detach
{
    GLenum attachment = GL_COLOR_ATTACHMENT0_EXT + colorBufferIndex;
    glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, attachment, GL_TEXTURE_2D, 0, 0);

    [[ configuration colorTargets ] replaceObjectAtIndex:colorBufferIndex withObject:[ NSNull null ]];

    ASSIGN(configuration, nil);
}

- (void) bindToRenderTargetConfiguration:(NPRenderTargetConfiguration *)newConfiguration
                        colorBufferIndex:(Int)newColorBufferIndex
{
    if ( configuration != newConfiguration )
    {
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
    }
}

@end
