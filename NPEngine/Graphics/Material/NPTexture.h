#import "Core/NPObject/NPObject.h"
#import "Graphics/npgl.h"
#import "Core/Resource/NPResource.h"
#import "Core/Resource/NPPResource.h"

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
    NPState mipmapping;
    NPState minFilter;
    NPState magFilter;
    Int anisotropy;
}
NpTextureFilterState;

void np_texture_filter_state_reset(NpTextureFilterState * textureFilterState);

typedef struct NpTextureWrapState
{
    NPState wrapS;
    NPState wrapT;
}
NpTextureWrapState;

void np_texture_wrap_state_reset(NpTextureWrapState * textureWrapState);

@interface NPTexture : NPResource < NPPResource >
{
    NpTextureFilterState textureFilterState;
    NpTextureWrapState textureWrapState;

    NPState dataFormat;
    NPState pixelFormat;

    Int width;
    Int height;

    UInt textureID;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (BOOL) loadFromFile:(NPFile *)file;
- (void) reset;
- (BOOL) isReady;

- (UInt) textureID;
- (void) generateGLTextureID;

- (void) setDataFormat:(NPState)newDataFormat;
- (void) setPixelFormat:(NPState)newPixelFormat;
- (void) setWidth:(Int)newWidth;
- (void) setHeight:(Int)newHeight;
- (void) setMipMapping:(NPState)newMipMapping;
- (void) setTextureMinFilter:(NPState)newTextureMinFilter;
- (void) setTextureMagFilter:(NPState)newTextureMagFilter;
- (void) setTextureAnisotropyFilter:(NPState)newTextureAnisotropyFilter;
- (void) setTextureWrapS:(NPState)newWrapS;
- (void) setTextureWrapT:(NPState)newWrapT;

- (void) uploadToGLWithoutImageData;
- (void) uploadToGLUsingImage:(NPImage *)image;
- (void) updateGLTextureState;

@end


