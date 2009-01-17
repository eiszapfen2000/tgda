#import "Core/NPObject/NPObject.h"

@class NPTexture;
@class NPRenderTargetConfiguration;

@interface NPRenderTexture : NPObject
{
	UInt renderTextureID;
    NpState type;
	NpState pixelFormat;
    NpState dataFormat;
    Int width;
    Int height;

    NPTexture * texture;
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
- (Int) height;
- (NpState) type;
- (NpState) pixelFormat;
- (NpState) dataFormat;
- (NPTexture *)texture;
- (UInt) renderTextureID;
- (UInt) colorBufferIndex;

- (void) setWidth:(Int)newWidth;
- (void) setHeight:(Int)newHeight;
- (void) setType:(NpState)newType;
- (void) setPixelFormat:(NpState)newPixelFormat;
- (void) setDataFormat:(NpState)newDataFormat;

- (void) createTexture;

- (void) bindToRenderTargetConfiguration:(NPRenderTargetConfiguration *)newConfiguration colorBufferIndex:(Int)newColorBufferIndex;
- (void) unbindFromRenderTargetConfiguration;

@end
