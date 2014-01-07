#include "Core/Basics/NpBasics.h"

typedef struct NpTextureFilterState
{
    NpState mipmapping;
    NpState minFilter;
    NpState magFilter;
    Int anisotropy;
}
NpTextureFilterState;

void np_texture_filter_state_reset(NpTextureFilterState * textureFilterState);
void np_texture3d_filter_state_reset(NpTextureFilterState * textureFilterState);

typedef struct NpTextureWrapState
{
    NpState wrapS;
    NpState wrapT;
    NpState wrapR;
}
NpTextureWrapState;

void np_texture_wrap_state_reset(NpTextureWrapState * textureWrapState);

