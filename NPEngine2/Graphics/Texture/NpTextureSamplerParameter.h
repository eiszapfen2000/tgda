#include "Graphics/NPEngineGraphicsEnums.h"

void set_texture2d_filter(NpTexture2DFilter filter);
void set_texture2d_wrap(NpTextureWrap s, NpTextureWrap t);
void set_texture2d_anisotropy(uint32_t anisotropy);
void set_texture2d_swizzle_mask(NpTextureColorFormat colorFormat);
