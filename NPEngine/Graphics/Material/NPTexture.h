#import "Core/NPObject/NPObject.h"
#import "Core/Resource/NPResource.h"
#import "NpTexture.h"
#import "Graphics/npgl.h"

@class NPFile;
@class NPImage;

@interface NPTexture : NPResource
{
    UInt textureID;

    Int width;
    Int height;

    NpState dataFormat;
    NpState pixelFormat;

    NpTextureFilterState textureFilterState;
    NpTextureWrapState textureWrapState;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) clear;
- (void) reset;

- (UInt) textureID;
- (NpState) dataFormat;
- (NpState) pixelFormat;
- (Int) width;
- (Int) height;
- (NpTextureFilterState *) textureFilterState;

- (void) setDataFormat:(NpState)newDataFormat;
- (void) setPixelFormat:(NpState)newPixelFormat;
- (void) setWidth:(Int)newWidth;
- (void) setHeight:(Int)newHeight;
- (void) setMipMapping:(NpState)newMipMapping;
- (void) setTextureFilter:(NpState)newTextureFilter;
- (void) setTextureMinFilter:(NpState)newTextureMinFilter;
- (void) setTextureMagFilter:(NpState)newTextureMagFilter;
- (void) setTextureAnisotropyFilter:(NpState)newTextureAnisotropyFilter;
- (void) setTextureWrap:(NpState)newWrap;
- (void) setTextureWrapS:(NpState)newWrapS;
- (void) setTextureWrapT:(NpState)newWrapT;

- (BOOL) loadFromFile:(NPFile *)file;
- (BOOL) loadFromFile:(NPFile *)file sRGB:(BOOL)sRGB;

- (void) uploadToGLWithoutData;
- (void) uploadToGLUsingImage:(NPImage *)image;
- (void) uploadToGLWithData:(NSData *)data;
- (void) uploadImage:(NPImage *)image toMipmapLevel:(Int32)level;
- (void) uploadData:(NSData *)data toMipmapLevel:(Int32)level;

- (NSData *) downloadMipmapFromGL:(Int32)level;
- (Int32) downloadMaxMipmapLevelIntoBytes:(Byte **)data;
- (Int32) downloadMaxMipmapLevelIntoHalfs:(Half **)data;
- (Int32) downloadMaxMipmapLevelIntoFloats:(Float **)data;

- (void) updateGLTextureState;

- (void) activateAtColorMapIndex:(Int32)index;

@end


