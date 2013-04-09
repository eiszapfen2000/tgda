#include <assert.h>
#include "GL/glew.h"
#include "NpTextureSamplerParameter.h"

void set_texture2d_filter(NpTexture2DFilter filter)
{
    GLint minFilter = GL_NONE;
    GLint magFilter = GL_NONE;

    switch ( filter )
    {
        case NpTexture2DFilterNearest:
        {
            minFilter = magFilter = GL_NEAREST;
            break;
        }

        case NpTexture2DFilterLinear:
        {
            minFilter = magFilter = GL_LINEAR;
            break;
        }

        case NpTexture2DFilterTrilinear:
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

void set_texture2d_swizzle_mask(NpTextureColorFormat colorFormat)
{
    //assert(colorFormat != NpTextureColorFormatUnknown);

    if ( colorFormat != NpTextureColorFormatUnknown )
    {
        glTexParameteriv(GL_TEXTURE_2D, GL_TEXTURE_SWIZZLE_RGBA, masks[colorFormat]);
    }
}

void set_sampler_filter(GLuint sampler, NpTexture2DFilter filter)
{
    GLint minFilter = GL_NONE;
    GLint magFilter = GL_NONE;

    switch ( filter )
    {
        case NpTexture2DFilterNearest:
        {
            minFilter = magFilter = GL_NEAREST;
            break;
        }

        case NpTexture2DFilterLinear:
        {
            minFilter = magFilter = GL_LINEAR;
            break;
        }

        case NpTexture2DFilterTrilinear:
        {
            minFilter = GL_LINEAR_MIPMAP_LINEAR;
            magFilter = GL_LINEAR;
        }
    }

    glSamplerParameteri(sampler, GL_TEXTURE_MIN_FILTER, minFilter);
    glSamplerParameteri(sampler, GL_TEXTURE_MAG_FILTER, magFilter);
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

