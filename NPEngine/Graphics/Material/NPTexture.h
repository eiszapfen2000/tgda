#import "Core/NPObject/NPObject.h"
#import "Core/Resource/NPResource.h"
#import "Graphics/npgl.h"

@class NPFile;
@class NPImage;

#define NP_TEXTURE_DATAFORMAT_BYTE                  0
#define NP_TEXTURE_DATAFORMAT_HALF                  1
#define NP_TEXTURE_DATAFORMAT_FLOAT                 2

#define NP_TEXTURE_PIXELFORMAT_R                    0
#define NP_TEXTURE_PIXELFORMAT_RG                   1
#define NP_TEXTURE_PIXELFORMAT_RGB                  2
#define NP_TEXTURE_PIXELFORMAT_RGBA                 3

#define NP_TEXTURE_FILTER_MIPMAPPING_INACTIVE       0
#define NP_TEXTURE_FILTER_MIPMAPPING_ACTIVE         1

#define NP_TEXTURE_FILTER_NEAREST                   0
#define NP_TEXTURE_FILTER_LINEAR                    1
#define NP_TEXTURE_FILTER_NEAREST_MIPMAP_NEAREST    2
#define NP_TEXTURE_FILTER_LINEAR_MIPMAP_NEAREST     3
#define NP_TEXTURE_FILTER_NEAREST_MIPMAP_LINEAR     4
#define NP_TEXTURE_FILTER_LINEAR_MIPMAP_LINEAR      5

#define NP_TEXTURE_WRAP_S                           0
#define NP_TEXTURE_WRAP_T                           1

#define NP_TEXTURE_WRAPPING_CLAMP                   0
#define NP_TEXTURE_WRAPPING_CLAMP_TO_EDGE           1
#define NP_TEXTURE_WRAPPING_CLAMP_TO_BORDER         2
#define NP_TEXTURE_WRAPPING_REPEAT                  3

#define NP_TEXTURE_FILTER_ANISOTROPY_1X             1
#define NP_TEXTURE_FILTER_ANISOTROPY_2X             2
#define NP_TEXTURE_FILTER_ANISOTROPY_4X             4
#define NP_TEXTURE_FILTER_ANISOTROPY_8X             8
#define NP_TEXTURE_FILTER_ANISOTROPY_16X            16

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

- (BOOL) loadFromFile:(NPFile *)file;
- (void) reset;

- (UInt) textureID;
- (void) generateGLTextureID;

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

- (void) uploadToGLWithoutImageData;
- (void) uploadToGLUsingImage:(NPImage *)image;
- (void) updateGLTextureState;

@end


