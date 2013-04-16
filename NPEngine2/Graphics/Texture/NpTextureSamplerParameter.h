#include "Graphics/NPEngineGraphicsEnums.h"

void set_texture2d_filter(NpTexture2DFilter filter);
void set_texture2d_wrap(NpTextureWrap s, NpTextureWrap t);
void set_texture2d_anisotropy(uint32_t anisotropy);
void set_texture2d_swizzle_mask(NpTextureColorFormat colorFormat);

void set_sampler_filter(GLuint sampler, NpTextureMinFilter minFilter, NpTextureMagFilter magFilter);
void set_sampler_wrap(GLuint sampler, NpTextureWrap s, NpTextureWrap t, NpTextureWrap r);
void set_sampler_anisotropy(GLuint sampler, uint32_t anisotropy);
