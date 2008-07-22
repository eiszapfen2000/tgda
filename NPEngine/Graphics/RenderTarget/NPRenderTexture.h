#import "Core/NPObject/NPObject.h"

#define NP_RENDERTEXTURE_COLOR_TYPE     0


@class NPTexture;
@class NPRenderTargetConfiguration;

@interface NPRenderTexture : NPObject
{
	UInt renderTextureID;

    NPTexture * texture;

    Int width;
    Int height;

    NPState type;

	NPState pixelFormat;
    NPState dataFormat;

    NPRenderTargetConfiguration * configuration;
    Int colorBufferIndex;

    BOOL ready;
}

+ (id) renderTextureWithName:(NSString *)name
                        type:(NPState)type
                  dataFormat:(NPState)dataFormat
                 pixelFormat:(NPState)pixelFormat
                       width:(Int)width
                      height:(Int)height;

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (Int) width;
- (void) setWidth:(Int)newWidth;
- (Int) height;
- (void) setHeight:(Int)newHeight;
- (NPState) type;
- (void) setType:(NPState)newType;
- (NPState) pixelFormat;
- (void) setPixelFormat:(NPState)newPixelFormat;
- (NPState) dataFormat;
- (void) setDataFormat:(NPState)newDataFormat;
- (NPTexture *)texture;

- (void) createTexture;

- (void) bindToRenderTargetConfiguration:(NPRenderTargetConfiguration *)newConfiguration colorBufferIndex:(Int)newColorBufferIndex;
- (void) unbindFromRenderTargetConfiguration;

@end
