#import "Core/NPObject/NPObject.h"
#import "Core/Resource/NPResource.h"
#import "Core/Resource/NPPResource.h"

@class NPFile;
@class NPImage;

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

void np_texture_filter_state_reset(NpTextureFilterState * textureFilterState);

typedef struct NpTextureWrapState
{
    Int wrapS;
    Int wrapT;
}
NpTextureWrapState;

void np_texture_wrap_state_reset(NpTextureWrapState * textureWrapState);

@interface NPTexture : NPResource < NPPResource >
{
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
- (void) reset;
- (BOOL) isReady;

- (void) activate;

- (void) setTextureFilterState:(NpTextureFilterState)newTextureFilterState;
- (void) setMipMapping:(BOOL)newMipMapping;
- (void) setTextureMinFilter:(Int)newTextureMinFilter;
- (void) setTextureMaxFilter:(Int)newTextureMaxFilter;
- (void) setTextureAnisotropyFilter:(Float)newTextureAnisotropyFilter;
- (void) setTextureWrapState:(NpTextureWrapState)newTextureWrapState;
- (void) setTextureWrapS:(Int)newWrapS;
- (void) setTextureWrapT:(Int)newWrapT;

- (void) setupGLWrapState;
- (void) setupGLFilterState;
- (void) setupGLFilterAndWrapState;
- (void) uploadToGL;

@end

