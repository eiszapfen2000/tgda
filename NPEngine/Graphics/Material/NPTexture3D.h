#import "Core/NPObject/NPObject.h"
#import "Core/Resource/NPResource.h"
#import "NpTexture.h"
#import "Graphics/npgl.h"

@class NPFile;
@class NPImage;

@interface NPTexture3D : NPObject
{
    UInt textureID;

    Int width;
    Int height;
    Int depth;

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
- (Int) depth;

- (void) setDataFormat:(NpState)newDataFormat;
- (void) setPixelFormat:(NpState)newPixelFormat;
- (void) setWidth:(Int)newWidth;
- (void) setHeight:(Int)newHeight;
- (void) setDepth:(Int)newDepth;
- (void) setResolution:(IVector3 *)newResolution;
- (void) setTextureFilter:(NpState)newTextureFilter;
- (void) setTextureMinFilter:(NpState)newTextureMinFilter;
- (void) setTextureMagFilter:(NpState)newTextureMagFilter;
- (void) setTextureWrap:(NpState)newWrap;
- (void) setTextureWrapS:(NpState)newWrapS;
- (void) setTextureWrapT:(NpState)newWrapT;

- (void) uploadToGLWithoutData;
- (void) uploadToGLWithData:(NSData *)data;
- (void) updateGLTextureState;

- (void) activateAtVolumeMapIndex:(Int32)index;

@end

