#include "NPEngineGraphicsEnums.h"

GLenum getGLTextureDataFormat(const NpTextureDataFormat dataFormat)
{
    GLenum result = GL_NONE;

    switch ( dataFormat )
    {
        case NpTextureDataFormatByte:
        {
            result = GL_UNSIGNED_BYTE;
            break;
        }

        case NpTextureDataFormatShort:
        {
            result = GL_SHORT;
            break;
        }

        case NpTextureDataFormatInt:
        {
            result = GL_INT;
            break;
        }

        case NpTextureDataFormatFloat16:
        {
            result = GL_HALF_FLOAT;
            break;
        }

        case NpTextureDataFormatFloat32:
        {
            result = GL_FLOAT;
            break;
        }

        default:
        {
            break;
        }
    }

    return result;
}

GLenum getGLTexturePixelFormat(const NpTexturePixelFormat pixelFormat)
{
    GLenum result = GL_NONE;

    switch ( pixelFormat )
    {
        case NpTexturePixelFormatR:
        {
            result = GL_RED;
            break;
        }

        case NpTexturePixelFormatRG:
        {
            result = GL_RG;
            break;
        }

        case NpTexturePixelFormatRGB:
        case NpTexturePixelFormatsRGB:
        {
            result = GL_RGB;
            break;
        }

        case NpTexturePixelFormatRGBA:
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
                                 const int sRGBSupport)
{
    GLint glinternalformat = 0;

    switch ( dataFormat )
    {
        case NpTextureDataFormatByte:
        {
            if ( !sRGBSupport )
            {
                switch ( pixelFormat )
                {
                    case NpTexturePixelFormatR :
                    {
                        glinternalformat = GL_R8;
                        break;
                    }

                    case NpTexturePixelFormatRG:
                    {
                        glinternalformat = GL_RG8;
                        break;
                    }

                    case NpTexturePixelFormatRGB:
                    case NpTexturePixelFormatsRGB:
                    {
                        glinternalformat = GL_RGB8;
                        break;
                    }

                    case NpTexturePixelFormatRGBA:
                    case NpTexturePixelFormatsRGBLinearA:
                    {
                        glinternalformat = GL_RGBA8;
                        break;
                    }

                    // do not handle depth and depthstencil

                    default: break;
                }
            }
            else
            {
                switch ( pixelFormat )
                {
                    case NpTexturePixelFormatR   : { glinternalformat = GL_R8;   break; }
                    case NpTexturePixelFormatRG  : { glinternalformat = GL_RG8;  break; }
                    case NpTexturePixelFormatRGB : { glinternalformat = GL_RGB8;  break; }
                    case NpTexturePixelFormatRGBA: { glinternalformat = GL_RGBA8; break; }
                    case NpTexturePixelFormatsRGB        : { glinternalformat = GL_SRGB8;        break; }
                    case NpTexturePixelFormatsRGBLinearA : { glinternalformat = GL_SRGB8_ALPHA8; break; }

                    // do not handle depth and depth stencil

                    default: break;
                }
            }

            break;
        }

        case NpTextureDataFormatShort:
        {
            switch ( pixelFormat )
            {
                case NpTexturePixelFormatR   : { glinternalformat = GL_R16I;   break; }
                case NpTexturePixelFormatRG  : { glinternalformat = GL_RG16I;  break; }
                case NpTexturePixelFormatRGB : { glinternalformat = GL_RGB16I;  break; }
                case NpTexturePixelFormatRGBA: { glinternalformat = GL_RGBA16I; break; }
                case NpTexturePixelFormatDepth: { glinternalformat = GL_DEPTH_COMPONENT16; break; }

                // do not handle srgb, srgb linear a, depth stencil

                default: break;
            }

            break;
        }

        case NpTextureDataFormatInt:
        {
            switch ( pixelFormat )
            {
                case NpTexturePixelFormatR   : { glinternalformat = GL_R32I;   break; }
                case NpTexturePixelFormatRG  : { glinternalformat = GL_RG32I;  break; }
                case NpTexturePixelFormatRGB : { glinternalformat = GL_RGB32I;  break; }
                case NpTexturePixelFormatRGBA: { glinternalformat = GL_RGBA32I; break; }
                case NpTexturePixelFormatDepth: { glinternalformat = GL_DEPTH_COMPONENT24; break; }
                case NpTexturePixelFormatDepthStencil: { glinternalformat = GL_DEPTH24_STENCIL8; break; }

                // do not handle srgb, srgb linear a, depth stencil

                default: break;
            }

            break;
        }

        case NpTextureDataFormatFloat16:
        {
            switch ( pixelFormat )
            {
                case NpTexturePixelFormatR   : { glinternalformat = GL_R16F;    break; }
                case NpTexturePixelFormatRG  : { glinternalformat = GL_RG16F;   break; }
                case NpTexturePixelFormatRGB : { glinternalformat = GL_RGB16F;  break; }
                case NpTexturePixelFormatRGBA: { glinternalformat = GL_RGBA16F; break; }
                default: break;

                // do not handle srgb, srgb linear a, depth and depth stencil
            }

            break;
        }

        case ( NpTextureDataFormatFloat32 ):
        {
            switch ( pixelFormat )
            {
                case NpTexturePixelFormatR   : { glinternalformat = GL_R32F;    break; }
                case NpTexturePixelFormatRG  : { glinternalformat = GL_RG32F;   break; }
                case NpTexturePixelFormatRGB : { glinternalformat = GL_RGB32F;  break; }
                case NpTexturePixelFormatRGBA: { glinternalformat = GL_RGBA32F; break; }
                case NpTexturePixelFormatDepth: { glinternalformat = GL_DEPTH_COMPONENT32F; break; }
                case NpTexturePixelFormatDepthStencil: { glinternalformat = GL_DEPTH32F_STENCIL8; break; }
                default: break;

                // do not handle srgb, srgb linear a
            }

            break;
        }

        default:
            break;
    }

    return glinternalformat;

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
	    case NpComparisonNever        : { result = GL_NEVER;   break; }
	    case NpComparisonAlways       : { result = GL_ALWAYS;  break; }
	    case NpComparisonLess         : { result = GL_LESS;    break; }
	    case NpComparisonLessEqual    : { result = GL_LEQUAL;  break; }
	    case NpComparisonEqual        : { result = GL_EQUAL;   break; }
	    case NpComparisonGreaterEqual : { result = GL_GEQUAL;  break; }
	    case NpComparisonGreater      : { result = GL_GREATER; break; }
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

GLenum getGLRenderBufferInternalFormat(const NpRenderTargetType Type,
            const NpRenderBufferPixelFormat PixelFormat,
            const NpRenderBufferDataFormat DataFormat)
{
    GLenum internalFormat = GL_NONE;

	switch (Type)
	{
	    case NpRenderTargetColor:
		{
			switch (DataFormat)
			{
			    case NpRenderBufferDataFormatByte:
				{
					switch (PixelFormat)
					{
					    case NpImagePixelFormatRGB:
                        {
						    internalFormat = GL_RGB8;
						    break;
                        }

					    case NpImagePixelFormatRGBA:
                        {
						    internalFormat = GL_RGBA8;
						    break;
                        }

                        default:
                        {
                            break;
                        }
					}

					break;
				}

    			case NpRenderBufferDataFormatFloat16:
				{
					switch (PixelFormat)
					{
					    case NpImagePixelFormatRGB:
                        {
						    internalFormat = GL_RGB16F;
						    break;
                        }

					    case NpImagePixelFormatRGBA:
                        {
						    internalFormat = GL_RGBA16F;
						    break;
                        }

                        default:
                        {
                            break;
                        }
                    }

					break;
				}

    			case NpRenderBufferDataFormatFloat32:
				{
					switch (PixelFormat)
					{
					    case NpImagePixelFormatRGB:
                        {
						    internalFormat = GL_RGB32F;
						    break;
                        }

					    case NpImagePixelFormatRGBA:
                        {
						    internalFormat = GL_RGBA32F;
						    break;
                        }

                        default:
                        {
                            break;
                        }
                    }

					break;
				}

                default:
                {
                    break;
                }
			}

			break;
		}

    	case NpRenderTargetDepth:
		{
			switch (DataFormat)
			{
			    case NpRenderBufferDataFormatDepth16:
                {
				    internalFormat = GL_DEPTH_COMPONENT16;
				    break;
                }

    			case NpRenderBufferDataFormatDepth24:
                {
				    internalFormat = GL_DEPTH_COMPONENT24;
				    break;
                }

    			case NpRenderBufferDataFormatDepth32:
                {
				    internalFormat = GL_DEPTH_COMPONENT32;
				    break;
                }

                case NpRenderBufferDataFormatFloat32:
                {
                    internalFormat = GL_DEPTH_COMPONENT32F;
                    break;
                }

                default:
                {
                    break;
                }
			}

			break;
		}

    	case NpRenderTargetDepthStencil:
		{
            switch (DataFormat)
            {
                case NpRenderBufferDataFormatDepth24:
                {
    				internalFormat = GL_DEPTH24_STENCIL8;
                    break;
                }

                case NpRenderBufferDataFormatFloat32:
                {
                    internalFormat = GL_DEPTH32F_STENCIL8;
                    break;
                }

                default:
                {
                    break;
                }
            }

			break;
		}

    	default:
		{
			break;
		}
	}

	return internalFormat;
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
                }

                case NpBufferDataUpdateOnceUseSeldom:
                {
                    result = GL_DYNAMIC_DRAW;
                }

                case NpBufferDataUpdateOftenUseOften:
                {
                    result = GL_STREAM_DRAW;
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
                }

                case NpBufferDataUpdateOnceUseSeldom:
                {
                    result = GL_DYNAMIC_READ;
                }

                case NpBufferDataUpdateOftenUseOften:
                {
                    result = GL_STREAM_READ;
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
                }

                case NpBufferDataUpdateOnceUseSeldom:
                {
                    result = GL_DYNAMIC_COPY;
                }

                case NpBufferDataUpdateOftenUseOften:
                {
                    result = GL_STREAM_COPY;
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
