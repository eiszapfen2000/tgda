#include "NPEngineGraphicsEnums.h"

NpTextureColorFormat getColorFormatForPixelFormat(const NpTexturePixelFormat pixelFormat)
{
    NpTextureColorFormat result = NpTextureColorFormatUnknown;

    switch ( pixelFormat )
    {
        case NpTexturePixelFormatR:
        case NpTexturePixelFormatDepth:
        case NpTexturePixelFormatDepthStencil:
        {
            result = NpTextureColorFormatRRR1;
            break;
        }

        case NpTexturePixelFormatRG:
        {
            result = NpTextureColorFormatRG01;
            break;
        }

        case NpTexturePixelFormatRGB:
        case NpTexturePixelFormatsRGB:
        {
            result = NpTextureColorFormatRGB1;
            break;
        }

        case NpTexturePixelFormatRGBA:
        case NpTexturePixelFormatsRGBLinearA:
        {
            result = NpTextureColorFormatRGBA;
            break;
        }

        default:
        {
            break;
        }
    }

    return result;
}

static GLenum getGLTextureDataFormat(const NpTexturePixelFormat pixelFormat, const NpTextureDataFormat dataFormat)
{
    GLenum result = GL_NONE;

    switch ( pixelFormat )
    {
        case NpTexturePixelFormatR:
        case NpTexturePixelFormatRG:
        case NpTexturePixelFormatRGB:
        case NpTexturePixelFormatRGBA:
        {
            switch ( dataFormat )
            {
                case NpTextureDataFormatUInt8N:
                case NpTextureDataFormatUInt8:
                { result = GL_UNSIGNED_BYTE; break; }

                case NpTextureDataFormatInt8N:
                case NpTextureDataFormatInt8:
                { result = GL_BYTE; break; }

                case NpTextureDataFormatUInt16N:
                case NpTextureDataFormatUInt16:
                { result = GL_UNSIGNED_SHORT; break; }

                case NpTextureDataFormatInt16N:
                case NpTextureDataFormatInt16:
                { result = GL_SHORT; break; }

                case NpTextureDataFormatUInt32N:
                case NpTextureDataFormatUInt32:
                { result = GL_UNSIGNED_INT; break; }

                case NpTextureDataFormatInt32N:
                case NpTextureDataFormatInt32:
                { result = GL_INT; break; }

                case NpTextureDataFormatFloat16:
                { result = GL_HALF_FLOAT; break; }

                case NpTextureDataFormatFloat32:
                { result = GL_FLOAT; break; }

                case NpTextureDataFormatFloat64:
                { result = GL_DOUBLE; break; }

                default: break;
            }

            break;
        }

        case NpTexturePixelFormatsRGB:
        case NpTexturePixelFormatsRGBLinearA:
        {
            switch ( dataFormat )
            {
                case NpTextureDataFormatUInt8N:
                case NpTextureDataFormatUInt8:
                { result = GL_UNSIGNED_BYTE; break; }
                default: break;
            }

            break;
        }

        case NpTexturePixelFormatDepth:
        {
            switch ( dataFormat )
            {
                case NpTextureDataFormatUInt16N:
                case NpTextureDataFormatInt16N:
                { result = GL_UNSIGNED_SHORT; break; }

                case NpTextureDataFormatUInt32N:
                case NpTextureDataFormatInt32N:
                { result = GL_UNSIGNED_INT; break; }

                case NpTextureDataFormatFloat32:
                { result = GL_FLOAT; break; }

                default: break;
            }

            break;
        }

        case NpTexturePixelFormatDepthStencil:
        {
            switch ( dataFormat )
            {
                case NpTextureDataFormatUInt32N:
                case NpTextureDataFormatInt32N:
                { result = GL_UNSIGNED_INT_24_8; break; }

                case NpTextureDataFormatFloat32:
                { result = GL_FLOAT_32_UNSIGNED_INT_24_8_REV; break; }

                default: break;
            }

            break;
        }

        default: break;
    }

    return result;
}

static GLenum getGLTexturePixelFormat(const NpTexturePixelFormat pixelFormat, const bool normalized)
{
    GLenum result = GL_NONE;

    switch ( pixelFormat )
    {
        case NpTexturePixelFormatR:
        {
            if ( normalized )
            {
                result = GL_RED;
            }
            else
            {
                result = GL_RED_INTEGER;
            }

            break;
        }

        case NpTexturePixelFormatRG:
        {
            if ( normalized )
            {
                result = GL_RG;
            }
            else
            {
                result = GL_RG_INTEGER;
            }

            break;
        }

        case NpTexturePixelFormatRGB:
        {
            if ( normalized )
            {
                result = GL_RGB;
            }
            else
            {
                result = GL_RGB_INTEGER;
            }

            break;
        }

        case NpTexturePixelFormatRGBA:
        {
            if ( normalized )
            {
                result = GL_RGBA;
            }
            else
            {
                result = GL_RGBA_INTEGER;
            }

            break;
        }

        case NpTexturePixelFormatsRGB:
        {
            result = GL_RGB;
            break;
        }

        case NpTexturePixelFormatsRGBLinearA:
        {
            result = GL_RGBA;
            break;
        }

        case NpTexturePixelFormatDepth:
        {
            result = GL_DEPTH_COMPONENT;
            break;
        }

        case NpTexturePixelFormatDepthStencil:
        {
            result = GL_DEPTH_STENCIL;
            break;
        }

        default:
        {
            break;
        }
    }

    return result;
}

GLint getGLTextureInternalFormat(const NpTextureDataFormat dataFormat,
                                 const NpTexturePixelFormat pixelFormat,
                                 const bool sRGBSupport,
                                 GLenum * glDataFormat,
                                 GLenum * glPixelFormat)
{
    GLint glinternalformat = 0;
    bool normalized = true;

    switch ( dataFormat )
    {
        // normalized
        case NpTextureDataFormatUInt8N:
        {
            switch ( pixelFormat )
            {
                case NpTexturePixelFormatR   : { glinternalformat = GL_R8;    break; }
                case NpTexturePixelFormatRG  : { glinternalformat = GL_RG8;   break; }
                case NpTexturePixelFormatRGB : { glinternalformat = GL_RGB8;  break; }
                case NpTexturePixelFormatRGBA: { glinternalformat = GL_RGBA8; break; }
                case NpTexturePixelFormatsRGB: { glinternalformat = GL_SRGB8;  break; }
                case NpTexturePixelFormatsRGBLinearA: { glinternalformat = GL_SRGB8_ALPHA8; break; }
                default: break;
            }
            break;
        }

        case NpTextureDataFormatInt8N:
        {
            switch ( pixelFormat )
            {
                case NpTexturePixelFormatR   : { glinternalformat = GL_R8_SNORM;    break; }
                case NpTexturePixelFormatRG  : { glinternalformat = GL_RG8_SNORM;   break; }
                case NpTexturePixelFormatRGB : { glinternalformat = GL_RGB8_SNORM;  break; }
                case NpTexturePixelFormatRGBA: { glinternalformat = GL_RGBA8_SNORM; break; }
                case NpTexturePixelFormatsRGB: { glinternalformat = GL_SRGB8;  break; }
                case NpTexturePixelFormatsRGBLinearA: { glinternalformat = GL_SRGB8_ALPHA8; break; }
                default: break;
            }
            break;
        }

        case NpTextureDataFormatUInt16N:
        {
            switch ( pixelFormat )
            {
                case NpTexturePixelFormatR   : { glinternalformat = GL_R16;    break; }
                case NpTexturePixelFormatRG  : { glinternalformat = GL_RG16;   break; }
                case NpTexturePixelFormatRGB : { glinternalformat = GL_RGB16;  break; }
                case NpTexturePixelFormatRGBA: { glinternalformat = GL_RGBA16; break; }
                case NpTexturePixelFormatDepth: { glinternalformat = GL_DEPTH_COMPONENT16; break; }
                default: break;
            }
            break;
        }

        case NpTextureDataFormatInt16N:
        {
            switch ( pixelFormat )
            {
                case NpTexturePixelFormatR   : { glinternalformat = GL_R16_SNORM;    break; }
                case NpTexturePixelFormatRG  : { glinternalformat = GL_RG16_SNORM;   break; }
                case NpTexturePixelFormatRGB : { glinternalformat = GL_RGB16_SNORM;  break; }
                case NpTexturePixelFormatRGBA: { glinternalformat = GL_RGBA16_SNORM; break; }
                case NpTexturePixelFormatDepth: { glinternalformat = GL_DEPTH_COMPONENT16; break; }
                default: break;
            }
            break;
        }

        case NpTextureDataFormatUInt32N:
        case NpTextureDataFormatInt32N:
        {
            switch ( pixelFormat )
            {
                case NpTexturePixelFormatDepth: { glinternalformat = GL_DEPTH_COMPONENT24; break; }
                case NpTexturePixelFormatDepthStencil: { glinternalformat = GL_DEPTH24_STENCIL8; break; }
                default: break;
            }
            break;
        }

        // floats
        case NpTextureDataFormatFloat16:
        {
            switch ( pixelFormat )
            {
                case NpTexturePixelFormatR   : { glinternalformat = GL_R16F;   break; }
                case NpTexturePixelFormatRG  : { glinternalformat = GL_RG16F;  break; }
                case NpTexturePixelFormatRGB : { glinternalformat = GL_RGB16F;  break; }
                case NpTexturePixelFormatRGBA: { glinternalformat = GL_RGBA16F; break; }
                default: break;
            }
            break;
        }

        case NpTextureDataFormatFloat32:
        {
            switch ( pixelFormat )
            {
                case NpTexturePixelFormatR   : { glinternalformat = GL_R32F;   break; }
                case NpTexturePixelFormatRG  : { glinternalformat = GL_RG32F;  break; }
                case NpTexturePixelFormatRGB : { glinternalformat = GL_RGB32F;  break; }
                case NpTexturePixelFormatRGBA: { glinternalformat = GL_RGBA32F; break; }
                case NpTexturePixelFormatDepth: { glinternalformat = GL_DEPTH_COMPONENT32F; break; }
                case NpTexturePixelFormatDepthStencil: { glinternalformat = GL_DEPTH32F_STENCIL8; break; }
                default: break;
            }
            break;
        }

        default:
        {
            normalized = false;
            break;
        }
    }

    switch ( dataFormat )
    {
        // non normalized ints
        case NpTextureDataFormatUInt8:
        {
            switch ( pixelFormat )
            {
                case NpTexturePixelFormatR   : { glinternalformat = GL_R8UI;    break; }
                case NpTexturePixelFormatRG  : { glinternalformat = GL_RG8UI;   break; }
                case NpTexturePixelFormatRGB : { glinternalformat = GL_RGB8UI;  break; }
                case NpTexturePixelFormatRGBA: { glinternalformat = GL_RGBA8UI; break; }
                default: break;
            }
            break;
        }

        case NpTextureDataFormatInt8:
        {
            switch ( pixelFormat )
            {
                case NpTexturePixelFormatR   : { glinternalformat = GL_R8I;    break; }
                case NpTexturePixelFormatRG  : { glinternalformat = GL_RG8I;   break; }
                case NpTexturePixelFormatRGB : { glinternalformat = GL_RGB8I;  break; }
                case NpTexturePixelFormatRGBA: { glinternalformat = GL_RGBA8I; break; }
                default: break;
            }
            break;
        }

        case NpTextureDataFormatUInt16:
        {
            switch ( pixelFormat )
            {
                case NpTexturePixelFormatR   : { glinternalformat = GL_R16UI;    break; }
                case NpTexturePixelFormatRG  : { glinternalformat = GL_RG16UI;   break; }
                case NpTexturePixelFormatRGB : { glinternalformat = GL_RGB16UI;  break; }
                case NpTexturePixelFormatRGBA: { glinternalformat = GL_RGBA16UI; break; }
                default: break;
            }
            break;
        }

        case NpTextureDataFormatInt16:
        {
            switch ( pixelFormat )
            {
                case NpTexturePixelFormatR   : { glinternalformat = GL_R16I;    break; }
                case NpTexturePixelFormatRG  : { glinternalformat = GL_RG16I;   break; }
                case NpTexturePixelFormatRGB : { glinternalformat = GL_RGB16I;  break; }
                case NpTexturePixelFormatRGBA: { glinternalformat = GL_RGBA16I; break; }
                default: break;
            }
            break;
        }

        case NpTextureDataFormatUInt32:
        {
            switch ( pixelFormat )
            {
                case NpTexturePixelFormatR   : { glinternalformat = GL_R32UI;    break; }
                case NpTexturePixelFormatRG  : { glinternalformat = GL_RG32UI;   break; }
                case NpTexturePixelFormatRGB : { glinternalformat = GL_RGB32UI;  break; }
                case NpTexturePixelFormatRGBA: { glinternalformat = GL_RGBA32UI; break; }
                default: break;
            }
            break;
        }

        case NpTextureDataFormatInt32:
        {
            switch ( pixelFormat )
            {
                case NpTexturePixelFormatR   : { glinternalformat = GL_R32I;    break; }
                case NpTexturePixelFormatRG  : { glinternalformat = GL_RG32I;   break; }
                case NpTexturePixelFormatRGB : { glinternalformat = GL_RGB32I;  break; }
                case NpTexturePixelFormatRGBA: { glinternalformat = GL_RGBA32I; break; }
                default: break;
            }
            break;
        }

        default:
        {
            break;
        }
    }

    if ( glDataFormat != NULL )
    {
        *glDataFormat = getGLTextureDataFormat(pixelFormat, dataFormat);
    }

    if ( glPixelFormat != NULL )
    {
        *glPixelFormat = getGLTexturePixelFormat(pixelFormat, normalized);
    }

    return glinternalformat;
}

GLint getGLTextureMinFilter(const NpTextureMinFilter filter)
{
    GLint result = GL_NONE;

    switch ( filter )
    {
        case NpTextureMinFilterNearest:
            result = GL_NEAREST;
            break;

        case NpTextureMinFilterLinear:
            result = GL_LINEAR;
            break;

        case NpTextureMinFilterTrilinear:
            result = GL_LINEAR_MIPMAP_LINEAR;
            break;
    }

    return result;
}

GLint getGLTextureMagFilter(const NpTextureMagFilter filter)
{
    GLint result = GL_NONE;

    switch ( filter )
    {
        case NpTextureMagFilterNearest:
            result = GL_NEAREST;
            break;

        case NpTextureMagFilterLinear:
            result = GL_LINEAR;
            break;
    }

    return result;
}

GLint getGLTextureWrap(const NpTextureWrap textureWrap)
{
    GLint result = GL_NONE;

    switch ( textureWrap )
    {
        case NpTextureWrapToBorder:
        {
            result = GL_CLAMP_TO_BORDER;
            break;
        }

        case NpTextureWrapToEdge:
        {
            result = GL_CLAMP_TO_EDGE;
            break;
        }

        case NpTextureWrapRepeat:
        {
            result = GL_REPEAT;
            break;
        }
    }

    return result;
}

GLenum getGLComparisonFunction(const NpComparisonFunction comparisonFunction)
{
    GLenum result = GL_NONE;

	switch (comparisonFunction)
	{
	    case NpComparisonNever        : { result = GL_NEVER;    break; }
	    case NpComparisonAlways       : { result = GL_ALWAYS;   break; }
	    case NpComparisonEqual        : { result = GL_EQUAL;    break; }
	    case NpComparisonNotEqual     : { result = GL_NOTEQUAL; break; }
	    case NpComparisonLess         : { result = GL_LESS;     break; }
	    case NpComparisonLessEqual    : { result = GL_LEQUAL;   break; }
	    case NpComparisonGreaterEqual : { result = GL_GEQUAL;   break; }
	    case NpComparisonGreater      : { result = GL_GREATER;  break; }
	}

    return result;
}

GLenum getGLCullface(const NpCullface cullface)
{
    GLenum result = GL_NONE;

    switch (cullface)
    {
        case NpCullfaceFront: { result = GL_FRONT; break; }
        case NpCullfaceBack : { result = GL_BACK;  break; }
    }

    return result;
}

GLenum getGLPolygonFillMode(const NpPolygonFillMode polygonFillMode)
{
    GLenum result = GL_NONE;

    switch (polygonFillMode)
    {
        case NpPolygonFillPoint: { result = GL_POINT; break; }
        case NpPolygonFillLine : { result = GL_LINE;  break; }
        case NpPolygonFillFace : { result = GL_FILL;  break; }
    }

    return result;
}

GLenum getGLStencilOperation(const NpStencilOperation stencilOperation)
{
    GLenum result = GL_NONE;

    switch ( stencilOperation )
    {
        case NpStencilKeepValue             : { result = GL_KEEP;      break; }
        case NpStencilSetZeroValue          : { result = GL_ZERO;      break; }
        case NpStencilSetReferenceValue     : { result = GL_REPLACE;   break; }
        case NpStencilInvertValue           : { result = GL_INVERT;    break; }
        case NpStencilIncrementValue        : { result = GL_INCR;      break; }
        case NpStencilIncrementAndWrapValue : { result = GL_INCR_WRAP; break; }
        case NpStencilDecrementValue        : { result = GL_DECR;      break; }
        case NpStencilDecrementAndWrapValue : { result = GL_DECR_WRAP; break; }
    }

    return result;
}

GLenum getGLBufferUsage(const NpBufferDataUpdateRate UpdateRate,
            const NpBufferDataUsage Usage)
{
    GLenum result = GL_NONE;

    switch ( Usage )
    {
        case NpBufferDataWriteCPUToGPU:
        {
            switch ( UpdateRate )
            {
                case NpBufferDataUpdateOnceUseOften:
                {
                    result = GL_STATIC_DRAW;
                    break;
                }

                case NpBufferDataUpdateOnceUseSeldom:
                {
                    result = GL_DYNAMIC_DRAW;
                    break;
                }

                case NpBufferDataUpdateOftenUseOften:
                {
                    result = GL_STREAM_DRAW;
                    break;
                }
            }

            break;
        }

        case NpBufferDataCopyGPUToCPU:
        {
            switch ( UpdateRate )
            {
                case NpBufferDataUpdateOnceUseOften:
                {
                    result = GL_STATIC_READ;
                    break;
                }

                case NpBufferDataUpdateOnceUseSeldom:
                {
                    result = GL_DYNAMIC_READ;
                    break;
                }

                case NpBufferDataUpdateOftenUseOften:
                {
                    result = GL_STREAM_READ;
                    break;
                }
            }

            break;
        }

        case NpBufferDataCopyGPUToGPU:
        {
            switch ( UpdateRate )
            {
                case NpBufferDataUpdateOnceUseOften:
                {
                    result = GL_STATIC_COPY;
                    break;
                }

                case NpBufferDataUpdateOnceUseSeldom:
                {
                    result = GL_DYNAMIC_COPY;
                    break;
                }

                case NpBufferDataUpdateOftenUseOften:
                {
                    result = GL_STREAM_COPY;
                    break;
                }
            }

            break;
        }
    }

    return result;
}

GLenum getCPUBufferType(const NpCPUBufferType Type)
{
    GLenum result = GL_NONE;

    switch ( Type )
    {
        case NpBufferObjectTypeGeometry:
            result = GL_ARRAY_BUFFER;
            break;
        case NpBufferObjectTypeIndices:
            result = GL_ELEMENT_ARRAY_BUFFER;
            break;
        default:
            break;
    }

    return result;
}

GLenum getGLBufferType(const NpBufferObjectType Type)
{
    GLenum result = GL_NONE;

    switch ( Type )
    {
        case NpBufferObjectTypeGeometry:
            result = GL_ARRAY_BUFFER;
            break;
        case NpBufferObjectTypeIndices:
            result = GL_ELEMENT_ARRAY_BUFFER;
            break;
        case NpBufferObjectTypePixelSource:
            result = GL_PIXEL_UNPACK_BUFFER;
            break;
        case NpBufferObjectTypePixelTarget:
            result = GL_PIXEL_PACK_BUFFER;
            break;
        case NpBufferObjectTypeTexture:
            result = GL_TEXTURE_BUFFER;
            break;
        case NpBufferObjectTypeUniforms:
            result = GL_UNIFORM_BUFFER;
            break;
        case NpBufferObjectTypeTransformFeedback:
            result = GL_TRANSFORM_FEEDBACK_BUFFER;
            break;
        default:
            break;
    }

    return result;
}

GLenum getGLBufferDataFormat(const NpBufferDataFormat DataFormat)
{
    GLenum result = GL_NONE;

    switch ( DataFormat )
    {
        case NpBufferDataFormatByte:
            result = GL_UNSIGNED_BYTE;
            break;
        case NpBufferDataFormatFloat16:
            result = GL_HALF_FLOAT;
            break;
        case NpBufferDataFormatFloat32:
            result = GL_FLOAT;
            break;
        case NpBufferDataFormatUInt16:
            result = GL_UNSIGNED_SHORT;
            break;
        case NpBufferDataFormatUInt32:
            result = GL_UNSIGNED_INT;
            break;

        default:
            break;
    }

    return result;
}

size_t numberOfBytesForDataFormat(const NpBufferDataFormat DataFormat)
{
    size_t result = 0;

    switch ( DataFormat )
    {
        case NpBufferDataFormatByte:
            result = 1;
            break;
        case NpBufferDataFormatFloat16:
        case NpBufferDataFormatUInt16:
            result = 2;
            break;
        case NpBufferDataFormatFloat32:
        case NpBufferDataFormatUInt32:
            result = 4;
            break;

        default:
            break;
    }

    return result;
}
