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
                       width:(Int)width
                      height:(Int)height
                  dataFormat:(NpState)dataFormat
                 pixelFormat:(NpState)pixelFormat
                            ;


+ (id) renderTextureWithName:(NSString *)name
                        type:(NpState)type
                       width:(Int)width
                      height:(Int)height
                  dataFormat:(NpState)dataFormat
                 pixelFormat:(NpState)pixelFormat
            textureFilter:(NpState)textureFilter
              textureWrap:(NpState)textureWrap
                            ;


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
- (void) createTextureWithTextureFilter:(NpState)textureFilter
                            textureWrap:(NpState)textureWrap
                                       ;

- (void) generateMipMaps;

- (void) attachToColorBufferIndex:(Int)newColorBufferIndex;
- (void) detach;

- (void) bindToRenderTargetConfiguration:(NPRenderTargetConfiguration *)newConfiguration
                        colorBufferIndex:(Int)newColorBufferIndex
                                        ;
- (void) unbindFromRenderTargetConfiguration;

@end
