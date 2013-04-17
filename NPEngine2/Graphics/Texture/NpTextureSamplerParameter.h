#include "Graphics/NPEngineGraphicsEnums.h"

typedef struct NpSamplerFilterState
{
	NpTextureMinFilter minFilter;
	NpTextureMagFilter magFilter;
	uint32_t anisotropy;
}
NpSamplerFilterState;

typedef struct NpSamplerWrapState
{
	NpTextureWrap wrapS;
	NpTextureWrap wrapT;
    NpTextureWrap wrapR;
}
NpSamplerWrapState;

void reset_sampler_filterstate(NpSamplerFilterState * filterState);
void reset_sampler_wrapstate(NpSamplerWrapState * wrapState);

void set_texture2d_filter(NpTexture2DFilter filter);
void set_texture2d_wrap(NpTextureWrap s, NpTextureWrap t);
void set_texture2d_anisotropy(uint32_t anisotropy);
void set_texture2d_swizzle_mask(NpTextureColorFormat colorFormat);

void set_sampler_filterstate(GLuint sampler, NpSamplerFilterState filterState);
void set_sampler_wrapstate(GLuint sampler, NpSamplerWrapState wrapState);

void set_sampler_filter(GLuint sampler, NpTextureMinFilter minFilter, NpTextureMagFilter magFilter);
void set_sampler_wrap(GLuint sampler, NpTextureWrap s, NpTextureWrap t, NpTextureWrap r);
void set_sampler_anisotropy(GLuint sampler, uint32_t anisotropy);
