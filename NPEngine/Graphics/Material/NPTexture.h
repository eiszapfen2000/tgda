#import "Core/NPObject/NPObject.h"
#import "Core/Resource/NPResource.h"
#import "Core/Resource/NPPResource.h"

@class NPFile;
@class NPImage;

typedef enum NPPixelFormat
{
    NP_PIXELFORMAT_NONE = 0,
    NP_PIXELFORMAT_BYTE_R = 1,
    NP_PIXELFORMAT_BYTE_RG = 2,
    NP_PIXELFORMAT_BYTE_RGB = 3,
    NP_PIXELFORMAT_BYTE_RGBA = 4,
    NP_PIXELFORMAT_FLOAT16_R = 5,
    NP_PIXELFORMAT_FLOAT16_RG = 6,
    NP_PIXELFORMAT_FLOAT16_RGB = 7,
    NP_PIXELFORMAT_FLOAT16_RGBA = 8,
    NP_PIXELFORMAT_FLOAT32_R = 9,
    NP_PIXELFORMAT_FLOAT32_RG = 10,
    NP_PIXELFORMAT_FLOAT32_RGB = 11,
    NP_PIXELFORMAT_FLOAT32_RGBA = 12
}
NPPixelFormat;

#define NP_TEXTURE_FILTER_NEAREST                   0
#define NP_TEXTURE_FILTER_LINEAR                    1
#define NP_TEXTURE_FILTER_NEAREST_MIPMAP_NEAREST    2
#define NP_TEXTURE_FILTER_LINEAR_MIPMAP_NEAREST     3
#define NP_TEXTURE_FILTER_NEAREST_MIPMAP_LINEAR     4
#define NP_TEXTURE_FILTER_LINEAR_MIPMAP_LINEAR      5

#define NP_TEXTURE_WRAPPING_CLAMP                   0
#define NP_TEXTURE_WRAPPING_CLAMP_TO_EDGE           1
#define NP_TEXTURE_WRAPPING_CLAMP_TO_BORDER         2
#define NP_TEXTURE_WRAPPING_REPEAT                  3

typedef struct NpTextureFilterState
{
    BOOL mipmapping;
    Int minFilter;
    Int magFilter;
    Float anisotropy;
}
NpTextureFilterState;

typedef struct NpTextureWrapState
{
    Int wrapS;
    Int wrapT;
}
NpTextureWrapState;

void np_texture_wrap_state_reset(NpTextureWrapState * textureWrapState);

void np_texture_filter_state_reset(NpTextureFilterState * textureFilterState);

@interface NPTexture : NPResource < NPPResource >
{
    NPPixelFormat pixelFormat;
    NpTextureFilterState textureFilterState;
    NpTextureWrapState textureWrapState;
    UInt textureID;
    NPImage * image;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (BOOL) loadFromFile:(NPFile *)file;
- (BOOL) loadFromFile:(NPFile *)file withMipMaps:(BOOL)generateMipMaps;
- (void) reset;
- (BOOL) isReady;

- (void) setTextureFilterState:(NpTextureFilterState)newTextureFilterState;
- (void) setMipMapping:(BOOL)newMipMapping;
- (void) setTextureMinFilter:(Int)newTextureMinFilter;
- (void) setTextureMaxFilter:(Int)newTextureMaxFilter;
- (void) setTextureAnisotropyFilter:(Float)newTextureAnisotropyFilter;
- (void) setTextureWrapState:(NpTextureWrapState)newTextureWrapState;
- (void) setTextureWrapS:(Int)newWrapS;
- (void) setTextureWrapT:(Int)newWrapT;

- (void) uploadToGL;

@end

