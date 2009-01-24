#include "NpTexture.h"
#include "Graphics/NPEngineGraphicsConstants.h"

void np_texture_filter_state_reset(NpTextureFilterState * textureFilterState)
{
    textureFilterState->mipmapping = 0;
    textureFilterState->minFilter  = NP_GRAPHICS_TEXTURE_FILTER_NEAREST_MIPMAP_LINEAR;
    textureFilterState->magFilter  = NP_GRAPHICS_TEXTURE_FILTER_LINEAR;
    textureFilterState->anisotropy = 1.0f;
}

void np_texture3d_filter_state_reset(NpTextureFilterState * textureFilterState)
{
    textureFilterState->mipmapping = 0;
    textureFilterState->minFilter  = NP_GRAPHICS_TEXTURE_FILTER_LINEAR;
    textureFilterState->magFilter  = NP_GRAPHICS_TEXTURE_FILTER_LINEAR;
    textureFilterState->anisotropy = 1.0f;
}

void np_texture_wrap_state_reset(NpTextureWrapState * textureWrapState)
{
    textureWrapState->wrapS = NP_GRAPHICS_TEXTURE_WRAPPING_REPEAT;
    textureWrapState->wrapT = NP_GRAPHICS_TEXTURE_WRAPPING_REPEAT;
    textureWrapState->wrapR = NP_GRAPHICS_TEXTURE_WRAPPING_REPEAT;
}
