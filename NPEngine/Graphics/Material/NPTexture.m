#import "NPTexture.h"
#import "Graphics/npgl.h"
#import "Graphics/Image/NPImageManager.h"
#import "Core/NPEngineCore.h"

#import "IL/il.h"
#import "IL/ilu.h"
#import "IL/ilut.h"

void np_texture_filter_state_reset(NpTextureFilterState * textureFilterState)
{
    textureFilterState->mipmapping = NO;
    textureFilterState->minFilter = NP_TEXTURE_FILTER_NEAREST_MIPMAP_LINEAR;
    textureFilterState->magFilter = NP_TEXTURE_FILTER_LINEAR;
    textureFilterState->anisotropy = 1.0f;
}

void np_texture_wrap_state_reset(NpTextureWrapState * textureWrapState)
{
    textureWrapState->wrapS = NP_TEXTURE_WRAPPING_REPEAT;
    textureWrapState->wrapT = NP_TEXTURE_WRAPPING_REPEAT;
}

@implementation NPTexture

- (id) init
{
    return [ self initWithName:@"NPTexture" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    //equals opengl default states
    np_texture_filter_state_reset(&textureFilterState);
    np_texture_wrap_state_reset(&textureWrapState);

    image = nil;

    return self;
}

- (void) dealloc
{
    [ self reset ];    

    [ super dealloc ];
}

- (BOOL) loadFromFile:(NPFile *)file
{
    return [ self loadFromFile:file withMipMaps:YES ];
}

- (BOOL) loadFromFile:(NPFile *)file withMipMaps:(BOOL)generateMipMaps
{
    [ self reset ];

    [ self setFileName:[ file fileName ] ];
    [ self setName:fileName ];

    image = [[[[NPEngineCore instance ] imageManager ] loadImageUsingFileHandle:file ] retain ];

	return YES;
}

- (void) reset
{
    glDeleteTextures(1, &textureID);

    np_texture_filter_state_reset(&textureFilterState);
    np_texture_wrap_state_reset(&textureWrapState);

    [ super reset ];
}

- (BOOL) isReady
{
    return ready;
}

- (void) setTextureFilterState:(NpTextureFilterState)newTextureFilterState
{
    textureFilterState = newTextureFilterState;
}

- (void) setMipMapping:(BOOL)newMipMapping
{
    if ( textureFilterState.mipmapping != newMipMapping )
    {
        textureFilterState.mipmapping = newMipMapping;
        
    }
}

- (void) setTextureMinFilter:(Int)newTextureMinFilter
{
    if ( textureFilterState.minFilter != newTextureMinFilter )
    {
        textureFilterState.minFilter = newTextureMinFilter;
        
    }
}

- (void) setTextureMaxFilter:(Int)newTextureMaxFilter
{
    if ( textureFilterState.magFilter != newTextureMaxFilter )
    {
        textureFilterState.magFilter = newTextureMaxFilter;
        
    }
}

- (void) setTextureAnisotropyFilter:(Float)newTextureAnisotropyFilter
{
    if ( textureFilterState.anisotropy != newTextureAnisotropyFilter )
    {
        textureFilterState.anisotropy = newTextureAnisotropyFilter;        
    }
}

- (void) setTextureWrapState:(NpTextureWrapState)newTextureWrapState
{
    textureWrapState = newTextureWrapState;
}

- (void) setTextureWrapS:(Int)newWrapS
{
    if ( textureWrapState.wrapS != newWrapS )
    {
        textureWrapState.wrapS = newWrapS;
    }
}

- (void) setTextureWrapT:(Int)newWrapT
{
    if ( textureWrapState.wrapT != newWrapT )
    {
        textureWrapState.wrapT = newWrapT;
    }
}

- (void) uploadToGL
{
    glGenTextures(1, &textureID);
}

@end
