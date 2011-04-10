#include "NPEngineGraphicsEnums.h"

GLenum getGLTextureDataFormat(const NpImageDataFormat dataFormat)
{
    GLenum result = GL_NONE;

    switch ( dataFormat )
    {
        case NpImageDataFormatByte:
        {
            result = GL_UNSIGNED_BYTE;
            break;
        }

        case NpImageDataFormatFloat16:
        {
            result = GL_HALF_FLOAT_ARB;
            break;
        }

        case NpImageDataFormatFloat32:
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

GLenum getGLTexturePixelFormat(const NpImagePixelFormat pixelFormat)
{
    GLenum result = GL_NONE;

    switch ( pixelFormat )
    {
        case NpImagePixelFormatR:
        case NpImagePixelFormatsR:
        {
            result = GL_LUMINANCE;
            break;
        }

        case NpImagePixelFormatRG:
        case NpImagePixelFormatsRG:
        {
            result = GL_LUMINANCE_ALPHA;
            break;
        }

        case NpImagePixelFormatRGB:
        case NpImagePixelFormatsRGB:
        {
            result = GL_RGB;
            break;
        }

        case NpImagePixelFormatRGBA:
        case NpImagePixelFormatsRGBLinearA:
        {
            result = GL_RGBA;
            break;
        }

        default:
        {
            break;
        }
    }

    return result;
}

GLint getGLTextureInternalFormat(const NpImageDataFormat dataFormat,
                                 const NpImagePixelFormat pixelFormat,
                                 const int sRGBSupport)
{
    GLint glinternalformat = 0;

    switch ( dataFormat )
    {
        case NpImageDataFormatByte:
        {
            if ( !sRGBSupport )
            {
                switch ( pixelFormat )
                {
                    case NpImagePixelFormatR :
                    case NpImagePixelFormatsR:
                    {
                        glinternalformat = GL_LUMINANCE;
                        break;
                    }

                    case NpImagePixelFormatRG:
                    case NpImagePixelFormatsRG:
                    {
                        glinternalformat = GL_LUMINANCE_ALPHA;
                        break;
                    }

                    case NpImagePixelFormatRGB:
                    case NpImagePixelFormatsRGB:
                    {
                        glinternalformat = GL_RGB;
                        break;
                    }

                    case NpImagePixelFormatRGBA:
                    case NpImagePixelFormatsRGBLinearA:
                    {
                        glinternalformat = GL_RGBA;
                        break;
                    }

                    default: break;
                }
            }
            else
            {
                switch ( pixelFormat )
                {
                    case NpImagePixelFormatR   : { glinternalformat = GL_LUMINANCE;       break; }
                    case NpImagePixelFormatRG  : { glinternalformat = GL_LUMINANCE_ALPHA; break; }
                    case NpImagePixelFormatRGB : { glinternalformat = GL_RGB;             break; }
                    case NpImagePixelFormatRGBA: { glinternalformat = GL_RGBA;            break; }

                    case NpImagePixelFormatsR         : { glinternalformat = GL_SLUMINANCE;       break; }
                    // this is buggy, since alpha is linear, luminance is not
                    case NpImagePixelFormatsRG        : { glinternalformat = GL_SLUMINANCE_ALPHA; break; }
                    case NpImagePixelFormatsRGB       : { glinternalformat = GL_SRGB;             break; }
                    case NpImagePixelFormatsRGBLinearA : { glinternalformat = GL_SRGB_ALPHA;       break; }

                    default: break;
                }
            }

            break;
        }

        case ( NpImageDataFormatFloat16 ):
        {
            switch ( pixelFormat )
            {
                case NpImagePixelFormatR   : { glinternalformat = GL_LUMINANCE16F_ARB;       break; }
                case NpImagePixelFormatRG  : { glinternalformat = GL_LUMINANCE_ALPHA16F_ARB; break; }
                case NpImagePixelFormatRGB : { glinternalformat = GL_RGB16F_ARB;             break; }
                case NpImagePixelFormatRGBA: { glinternalformat = GL_RGBA16F_ARB;            break; }
                default: break;
            }

            break;
        }

        case ( NpImageDataFormatFloat32 ):
        {
            switch ( pixelFormat )
            {
                case NpImagePixelFormatR   : { glinternalformat = GL_LUMINANCE32F_ARB;       break; }
                case NpImagePixelFormatRG  : { glinternalformat = GL_LUMINANCE_ALPHA32F_ARB; break; }
                case NpImagePixelFormatRGB : { glinternalformat = GL_RGB32F_ARB;             break; }
                case NpImagePixelFormatRGBA: { glinternalformat = GL_RGBA32F_ARB;            break; }
                default: break;
            }

            break;
        }

        default:
            break;
    }

    return glinternalformat;

}

/*
typedef enum NpImagePixelFormat
{
    NpImagePixelFormatUnknown = -1,
    NpImagePixelFormatR = 0,
    NpImagePixelFormatRG = 1,
    NpImagePixelFormatRGB = 2,
    NpImagePixelFormatRGBA = 3,
    NpImagePixelFormatsR = 4,
    NpImagePixelFormatsRG = 5,
    NpImagePixelFormatsRGB = 6,
    NpImagePixelFormatsRGBLinearA = 7    
}
NpImagePixelFormat;

typedef enum NpImageDataFormat
{
    NpImageDataFormatUnknown = -1,
    NpImageDataFormatByte = 0,
    NpImageDataFormatFloat16 = 1,
    NpImageDataFormatFloat32 = 2
}
NpImageDataFormat;
*/

GLenum getGLTextureWrap(const NpTextureWrap textureWrap)
{
    GLenum result = GL_NONE;

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

                default:
                {
                    break;
                }
			}

			break;
		}

    	case NpRenderTargetStencil:
		{
			switch (DataFormat)
			{
			    case NpRenderBufferDataFormatStencil8:
                {
				    internalFormat = GL_STENCIL_INDEX8;
				    break;
                }

    			case NpRenderBufferDataFormatStencil16:
                {
				    internalFormat = GL_STENCIL_INDEX16;
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
			if (DataFormat == NpRenderBufferDataFormatDepth24Stencil8)
			{
				internalFormat = GL_DEPTH24_STENCIL8;
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
                    result = GL_STREAM_DRAW;
                }

                case NpBufferDataUpdateOftenUseOften:
                {
                    result = GL_DYNAMIC_DRAW;
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
                    result = GL_STREAM_READ;
                }

                case NpBufferDataUpdateOftenUseOften:
                {
                    result = GL_DYNAMIC_READ;
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
                    result = GL_STREAM_COPY;
                }

                case NpBufferDataUpdateOftenUseOften:
                {
                    result = GL_DYNAMIC_COPY;
                }
            }

            break;
        }
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
