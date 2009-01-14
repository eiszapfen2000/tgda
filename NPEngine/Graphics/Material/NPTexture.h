#import "Core/NPObject/NPObject.h"
#import "Core/Resource/NPResource.h"
#import "Graphics/npgl.h"

@class NPFile;
@class NPImage;

typedef struct NpTextureFilterState
{
    NpState mipmapping;
    NpState minFilter;
    NpState magFilter;
    Int anisotropy;
}
NpTextureFilterState;

void np_texture_filter_state_reset(NpTextureFilterState * textureFilterState);

typedef struct NpTextureWrapState
{
    NpState wrapS;
    NpState wrapT;
}
NpTextureWrapState;

void np_texture_wrap_state_reset(NpTextureWrapState * textureWrapState);

@interface NPTexture : NPResource
{
    NpTextureFilterState textureFilterState;
    NpTextureWrapState textureWrapState;

    NpState dataFormat;
    NpState pixelFormat;

    Int width;
    Int height;

    UInt textureID;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) generateGLTextureID;

- (void) reset;

- (UInt) textureID;
- (NpState) dataFormat;
- (NpState) pixelFormat;
- (Int) width;
- (Int) height;

- (void) setDataFormat:(NpState)newDataFormat;
- (void) setPixelFormat:(NpState)newPixelFormat;
- (void) setWidth:(Int)newWidth;
- (void) setHeight:(Int)newHeight;
- (void) setMipMapping:(NpState)newMipMapping;
- (void) setTextureMinFilter:(NpState)newTextureMinFilter;
- (void) setTextureMagFilter:(NpState)newTextureMagFilter;
- (void) setTextureAnisotropyFilter:(NpState)newTextureAnisotropyFilter;
- (void) setTextureWrapS:(NpState)newWrapS;
- (void) setTextureWrapT:(NpState)newWrapT;

- (BOOL) loadFromFile:(NPFile *)file;

- (void) uploadToGLWithoutImageData;
- (void) uploadToGLUsingImage:(NPImage *)image;
- (void) updateGLTextureState;

@end


