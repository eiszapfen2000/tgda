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

    NpState type;

	NpState pixelFormat;
    NpState dataFormat;

    NPRenderTargetConfiguration * configuration;
    Int colorBufferIndex;

    BOOL ready;
}

+ (id) renderTextureWithName:(NSString *)name
                        type:(NpState)type
                  dataFormat:(NpState)dataFormat
                 pixelFormat:(NpState)pixelFormat
                       width:(Int)width
                      height:(Int)height;

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (Int) width;
- (void) setWidth:(Int)newWidth;
- (Int) height;
- (void) setHeight:(Int)newHeight;
- (NpState) type;
- (void) setType:(NpState)newType;
- (NpState) pixelFormat;
- (void) setPixelFormat:(NpState)newPixelFormat;
- (NpState) dataFormat;
- (void) setDataFormat:(NpState)newDataFormat;
- (NPTexture *)texture;

- (void) createTexture;

- (void) bindToRenderTargetConfiguration:(NPRenderTargetConfiguration *)newConfiguration colorBufferIndex:(Int)newColorBufferIndex;
- (void) unbindFromRenderTargetConfiguration;

@end
