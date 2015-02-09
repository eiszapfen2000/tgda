#include <assert.h>
#include "GL/glew.h"
#include "NpTextureSamplerParameter.h"

void reset_sampler_filterstate(NpSamplerFilterState * filterState)
{
    filterState->minFilter = NpTextureMinFilterNearest;
    filterState->magFilter = NpTextureMagFilterNearest;
    filterState->anisotropy = 1;
}

void reset_sampler_wrapstate(NpSamplerWrapState * wrapState)
{
    wrapState->wrapS = NpTextureWrapToEdge;
    wrapState->wrapT = NpTextureWrapToEdge;
    wrapState->wrapR = NpTextureWrapToEdge;
}

static const GLint masks[][4]
    = {
        {GL_RED, GL_RED, GL_RED, GL_ZERO},
        {GL_RED, GL_RED, GL_RED, GL_ONE},
        {GL_GREEN, GL_GREEN, GL_GREEN, GL_ZERO},
        {GL_GREEN, GL_GREEN, GL_GREEN, GL_ONE},
        {GL_BLUE, GL_BLUE, GL_BLUE, GL_ZERO},
        {GL_BLUE, GL_BLUE, GL_BLUE, GL_ONE},
        {GL_ALPHA, GL_ALPHA, GL_ALPHA, GL_ZERO},
        {GL_ALPHA, GL_ALPHA, GL_ALPHA, GL_ONE},
        {GL_RED, GL_GREEN, GL_ZERO, GL_ZERO},
        {GL_RED, GL_GREEN, GL_ZERO, GL_ONE},
        {GL_RED, GL_GREEN, GL_BLUE, GL_ZERO},
        {GL_RED, GL_GREEN, GL_BLUE, GL_ONE},
        {GL_RED, GL_GREEN, GL_BLUE, GL_ALPHA}
      };

void set_texture2d_filter(NpTexture2DFilter filter)
{
    GLint minFilter = GL_NONE;
    GLint magFilter = GL_NONE;

    switch ( filter )
    {
        case NpTextureFilterNearest:
        {
            minFilter = magFilter = GL_NEAREST;
            break;
        }

        case NpTextureFilterLinear:
        {
            minFilter = magFilter = GL_LINEAR;
            break;
        }

        case NpTextureFilterTrilinear:
        {
            minFilter = GL_LINEAR_MIPMAP_LINEAR;
            magFilter = GL_LINEAR;
        }
    }

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, minFilter);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, magFilter);
}

void set_texture2d_wrap(NpTextureWrap s, NpTextureWrap t)
{
    GLint wrapS = getGLTextureWrap(s);
    GLint wrapT = getGLTextureWrap(t);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, wrapS);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, wrapT);
}

void set_texture2d_anisotropy(uint32_t anisotropy)
{
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT,
                    (GLint)anisotropy);
}

void set_texture2d_swizzle_mask(NpTextureColorFormat colorFormat)
{
    //assert(colorFormat != NpTextureColorFormatUnknown);

    if ( colorFormat != NpTextureColorFormatUnknown )
    {
        glTexParameteriv(GL_TEXTURE_2D, GL_TEXTURE_SWIZZLE_RGBA, masks[colorFormat]);
    }
}

void set_texture2darray_filter(NpTexture2DFilter filter)
{
    GLint minFilter = GL_NONE;
    GLint magFilter = GL_NONE;

    switch ( filter )
    {
        case NpTextureFilterNearest:
        {
            minFilter = magFilter = GL_NEAREST;
            break;
        }

        case NpTextureFilterLinear:
        {
            minFilter = magFilter = GL_LINEAR;
            break;
        }

        case NpTextureFilterTrilinear:
        {
            minFilter = GL_LINEAR_MIPMAP_LINEAR;
            magFilter = GL_LINEAR;
        }
    }

    glTexParameteri(GL_TEXTURE_2D_ARRAY, GL_TEXTURE_MIN_FILTER, minFilter);
    glTexParameteri(GL_TEXTURE_2D_ARRAY, GL_TEXTURE_MAG_FILTER, magFilter);
}

void set_texture2darray_wrap(NpTextureWrap s, NpTextureWrap t)
{
    GLint wrapS = getGLTextureWrap(s);
    GLint wrapT = getGLTextureWrap(t);

    glTexParameteri(GL_TEXTURE_2D_ARRAY, GL_TEXTURE_WRAP_S, wrapS);
    glTexParameteri(GL_TEXTURE_2D_ARRAY, GL_TEXTURE_WRAP_T, wrapT);
}

void set_texture2darray_anisotropy(uint32_t anisotropy)
{
    glTexParameteri(GL_TEXTURE_2D_ARRAY, GL_TEXTURE_MAX_ANISOTROPY_EXT,
                    (GLint)anisotropy);
}

void set_texture2darray_swizzle_mask(NpTextureColorFormat colorFormat)
{
    //assert(colorFormat != NpTextureColorFormatUnknown);

    if ( colorFormat != NpTextureColorFormatUnknown )
    {
        glTexParameteriv(GL_TEXTURE_2D_ARRAY, GL_TEXTURE_SWIZZLE_RGBA, masks[colorFormat]);
    }
}

void set_texture3d_filter(NpTexture3DFilter filter)
{
    GLint minFilter = GL_NONE;
    GLint magFilter = GL_NONE;

    switch ( filter )
    {
        case NpTextureFilterNearest:
        {
            minFilter = magFilter = GL_NEAREST;
            break;
        }

        case NpTextureFilterLinear:
        {
            minFilter = magFilter = GL_LINEAR;
            break;
        }

        case NpTextureFilterTrilinear:
        {
            minFilter = GL_LINEAR_MIPMAP_LINEAR;
            magFilter = GL_LINEAR;
        }
    }

    glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MIN_FILTER, minFilter);
    glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MAG_FILTER, magFilter);
}

void set_texture3d_wrap(NpTextureWrap s, NpTextureWrap t, NpTextureWrap r)
{
    GLint wrapS = getGLTextureWrap(s);
    GLint wrapT = getGLTextureWrap(t);
    GLint wrapR = getGLTextureWrap(r);

    glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_S, wrapS);
    glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_T, wrapT);
    glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_R, wrapR);
}

void set_texture3d_anisotropy(uint32_t anisotropy)
{
    glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MAX_ANISOTROPY_EXT,
                    (GLint)anisotropy);
}

void set_texture3d_swizzle_mask(NpTextureColorFormat colorFormat)
{
    //assert(colorFormat != NpTextureColorFormatUnknown);

    if ( colorFormat != NpTextureColorFormatUnknown )
    {
        glTexParameteriv(GL_TEXTURE_3D, GL_TEXTURE_SWIZZLE_RGBA, masks[colorFormat]);
    }
}

void set_sampler_filterstate(GLuint sampler, NpSamplerFilterState filterState)
{
    GLint minGLFilter = getGLTextureMinFilter(filterState.minFilter);
    GLint magGLFilter = getGLTextureMagFilter(filterState.magFilter);

    glSamplerParameteri(sampler, GL_TEXTURE_MIN_FILTER, minGLFilter);
    glSamplerParameteri(sampler, GL_TEXTURE_MAG_FILTER, magGLFilter);

    glSamplerParameteri(sampler, GL_TEXTURE_MAX_ANISOTROPY_EXT, (GLint)(filterState.anisotropy));
}

void set_sampler_wrapstate(GLuint sampler, NpSamplerWrapState wrapState)
{
    GLint wrapS = getGLTextureWrap(wrapState.wrapS);
    GLint wrapT = getGLTextureWrap(wrapState.wrapT);
    GLint wrapR = getGLTextureWrap(wrapState.wrapR);

    glSamplerParameteri(sampler, GL_TEXTURE_WRAP_S, wrapS);
    glSamplerParameteri(sampler, GL_TEXTURE_WRAP_T, wrapT);
    glSamplerParameteri(sampler, GL_TEXTURE_WRAP_R, wrapR);
}

void set_sampler_filter(GLuint sampler, NpTextureMinFilter minFilter, NpTextureMagFilter magFilter)
{
    GLint minGLFilter = getGLTextureMinFilter(minFilter);
    GLint magGLFilter = getGLTextureMagFilter(magFilter);

    glSamplerParameteri(sampler, GL_TEXTURE_MIN_FILTER, minGLFilter);
    glSamplerParameteri(sampler, GL_TEXTURE_MAG_FILTER, magGLFilter);
}

void set_sampler_wrap(GLuint sampler, NpTextureWrap s, NpTextureWrap t, NpTextureWrap r)
{
    GLint wrapS = getGLTextureWrap(s);
    GLint wrapT = getGLTextureWrap(t);
    GLint wrapR = getGLTextureWrap(r);

    glSamplerParameteri(sampler, GL_TEXTURE_WRAP_S, wrapS);
    glSamplerParameteri(sampler, GL_TEXTURE_WRAP_T, wrapT);
    glSamplerParameteri(sampler, GL_TEXTURE_WRAP_R, wrapR);
}

void set_sampler_anisotropy(GLuint sampler, uint32_t anisotropy)
{
    glSamplerParameteri(sampler, GL_TEXTURE_MAX_ANISOTROPY_EXT, (GLint)anisotropy);
}

