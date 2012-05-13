#ifndef NPENGINEGRAPHICSENUMS_H_
#define NPENGINEGRAPHICSENUMS_H_

#include <stdbool.h>
#include "GL/glew.h"

// these are compatible with NpTexturePixelFormat
typedef enum NpImagePixelFormat
{
    NpImagePixelFormatUnknown     = -1,
    NpImagePixelFormatR           =  0,
    NpImagePixelFormatRG          =  1,
    NpImagePixelFormatRGB         =  2,
    NpImagePixelFormatRGBA        =  3,
    NpImagePixelFormatsRGB        =  4,
    NpImagePixelFormatsRGBLinearA =  5
}
NpImagePixelFormat;

// these are compatible with NpTextureDataFormat
typedef enum NpImageDataFormat
{
    NpImageDataFormatUnknown = -1,
    NpImageDataFormatUInt8N  =  0,
    NpImageDataFormatInt8N   =  1,
    NpImageDataFormatUInt16  =  6,
    NpImageDataFormatInt16   =  7,
    NpImageDataFormatUInt32  =  10,
    NpImageDataFormatInt32   =  11,
    NpImageDataFormatFloat16 =  12,
    NpImageDataFormatFloat32 =  13,
    NpImageDataFormatFloat64 =  14
}
NpImageDataFormat;

typedef enum NpTextureType
{
    NpTextureTypeUnknown       = -1,
    NpTextureTypeTexture1D     =  0,
    NpTextureTypeTexture2D     =  1,
    NpTextureTypeTexture3D     =  2,
    NpTextureTypeTextureCube   =  3,
    NpTextureTypeTextureBuffer =  4
}
NpTextureType;

typedef enum NpTexture2DFilter
{
    NpTexture2DFilterNearest   = 0,
    NpTexture2DFilterLinear    = 1,
    NpTexture2DFilterTrilinear = 2
}
NpTexture2DFilter;

typedef enum NpTextureWrap
{
    NpTextureWrapToBorder = 0,
    NpTextureWrapToEdge   = 1,
    NpTextureWrapRepeat   = 2
}
NpTextureWrap;

typedef enum NpTexturePixelFormat
{
    NpTexturePixelFormatUnknown      = -1,
    NpTexturePixelFormatR            =  0,
    NpTexturePixelFormatRG           =  1,
    NpTexturePixelFormatRGB          =  2,
    NpTexturePixelFormatRGBA         =  3,
    NpTexturePixelFormatsRGB         =  4,
    NpTexturePixelFormatsRGBLinearA  =  5,
    NpTexturePixelFormatDepth        =  6,
    NpTexturePixelFormatDepthStencil =  7
}
NpTexturePixelFormat;

typedef enum NpTextureDataFormat
{
    NpTextureDataFormatUnknown = -1,
    NpTextureDataFormatUInt8N  =  0,
    NpTextureDataFormatInt8N   =  1,
    NpTextureDataFormatUInt8   =  2,
    NpTextureDataFormatInt8    =  3,
    NpTextureDataFormatUInt16N =  4,
    NpTextureDataFormatInt16N  =  5,
    NpTextureDataFormatUInt16  =  6,
    NpTextureDataFormatInt16   =  7,
    NpTextureDataFormatUInt32N =  8,
    NpTextureDataFormatInt32N  =  9,
    NpTextureDataFormatUInt32  =  10,
    NpTextureDataFormatInt32   =  11,
    NpTextureDataFormatFloat16 =  12,
    NpTextureDataFormatFloat32 =  13,
    NpTextureDataFormatFloat64 =  14
}
NpTextureDataFormat;

typedef enum NpShaderType
{
    NpShaderTypeUnknown  = -1,
    NpShaderTypeVertex   =  0,
    NpShaderTypeFragment =  1
}
NpShaderType;

typedef enum NpEffectVariableType
{
    NpEffectVariableTypeUnknown  = -1,
    NpEffectVariableTypeSemantic =  0,
    NpEffectVariableTypeSampler  =  1,
    NpEffectVariableTypeUniform  =  2
}
NpEffectVariableType;

typedef enum NpEffectSemantic
{
    NpSemanticUnknown             = -1,
    NpModelMatrix                 =  0,
    NpInverseModelMatrix          =  1,
    NpViewMatrix                  =  2,
    NpInverseViewMatrix           =  3,
    NpProjectionMatrix            =  4,
    NpInverseProjectionMatrix     =  5,
    NpModelViewMatrix             =  6,
    NpInverseModelViewMatrix      =  7,
    NpViewProjectionMatrix        =  8,
    NpInverseViewProjectionMatrix =  9,
    NpModelViewProjectionMatrix   =  10,
    NpInverseModelViewProjection  =  11
}
NpEffectSemantic;

typedef enum NpUniformType
{
    NpUniformUnknown = -1,
    NpUniformFloat,
    NpUniformFloat2,
    NpUniformFloat3,
    NpUniformFloat4,
    NpUniformInt,
    NpUniformInt2,
    NpUniformInt3,
    NpUniformInt4,
    NpUniformFMatrix2x2,
    NpUniformFMatrix3x3,
    NpUniformFMatrix4x4
}
NpUniformType;

typedef enum NpVertexAttributeType
{
    NpVertexAttributeUnknown = -1,
    NpVertexAttributeFloat,
    NpVertexAttributeFloat2,
    NpVertexAttributeFloat3,
    NpVertexAttributeFloat4,
    NpVertexAttributeInt,
    NpVertexAttributeInt2,
    NpVertexAttributeInt3,
    NpVertexAttributeInt4
}
NpVertexAttributeType;

typedef enum NpComparisonFunction
{
    NpComparisonNever        = 0,
    NpComparisonAlways       = 1,
    NpComparisonLess         = 2,
    NpComparisonLessEqual    = 3,
    NpComparisonEqual        = 4,
    NpComparisonGreaterEqual = 5,
    NpComparisonGreater      = 6
}
NpComparisonFunction;

typedef enum NpBlendingMode
{
    NpBlendingAdditive    = 0,
    NpBlendingSubtractive = 1,
    NpBlendingAverage     = 2,
    NpBlendingMin         = 3,
    NpBlendingMax         = 4
}
NpBlendingMode;

typedef enum NpCullface
{
    NpCullfaceFront = 0,
    NpCullfaceBack  = 1
}
NpCullface;

typedef enum NpPolygonFillMode
{
    NpPolygonFillPoint = 0,
    NpPolygonFillLine  = 1,
    NpPolygonFillFace  = 2
}
NpPolygonFillMode;

typedef enum NpGeometryDataFormat
{
    NpGeometryDataFormatUnknown = -1,
    NpGeometryDataFormatInt8    =  0,
    NpGeometryDataFormatInt16   =  1,
    NpGeometryDataFormatInt32   =  2,
    NpGeometryDataFormatFloat16 =  3,
    NpGeometryDataFormatFloat32 =  4
}
NpGeometryDataFormat;

typedef enum NpRenderTargetType
{
    NpRenderTargetUnknown      = -1,
    NpRenderTargetColor        =  0,
	NpRenderTargetDepth        =  1,
    NpRenderTargetDepthStencil =  2
}
NpRenderTargetType;

typedef enum NpRenderBufferDataFormat
{
    NpRenderBufferDataFormatUnknown = -1,
    NpRenderBufferDataFormatByte    =  0,
    NpRenderBufferDataFormatFloat16 =  1,
    NpRenderBufferDataFormatFloat32 =  2,
    NpRenderBufferDataFormatDepth16 =  3,
    NpRenderBufferDataFormatDepth24 =  4,
    NpRenderBufferDataFormatDepth32 =  5
}
NpRenderBufferDataFormat;

typedef NpImagePixelFormat NpRenderBufferPixelFormat;

typedef enum NpBufferDataUpdateRate
{
    NpBufferDataUpdateOnceUseOften,
    NpBufferDataUpdateOnceUseSeldom,
    NpBufferDataUpdateOftenUseOften,
}
NpBufferDataUpdateRate;

typedef enum NpBufferDataUsage
{
    NpBufferDataWriteCPUToGPU,
    NpBufferDataCopyGPUToCPU,
    NpBufferDataCopyGPUToGPU
}
NpBufferDataUsage;

typedef enum NpBufferDataFormat
{
    NpBufferDataFormatUnknown = -1,
    NpBufferDataFormatByte    =  0,
    NpBufferDataFormatFloat16 =  1,
    NpBufferDataFormatFloat32 =  2,
    NpBufferDataFormatUInt16  =  3,
    NpBufferDataFormatUInt32  =  4,
}
NpBufferDataFormat;

typedef enum NpCPUBufferType
{
    NpCPUBufferTypeUnknown  = -1,
    NpCPUBufferTypeGeometry =  0,
    NpCPUBufferTypeIndices  =  1
}
NpCPUBufferType;

typedef enum NpBufferObjectType
{
    NpBufferObjectTypeUnknown           = -1,
    NpBufferObjectTypeGeometry          =  0,
    NpBufferObjectTypeIndices           =  1,
    NpBufferObjectTypePixelSource       =  2,
    NpBufferObjectTypePixelTarget       =  3,
    NpBufferObjectTypeUniforms          =  4,
    NpBufferObjectTypeTransformFeedback =  5
}
NpBufferObjectType;

typedef enum NpVertexStreamSemantic
{
    NpVertexStreamPositions = 0,
    NpVertexStreamNormals = 1,
    NpVertexStreamColors = 2,
    NpVertexStreamTexCoords  = 3,
    NpVertexStreamTexCoords0 = 3,
    NpVertexStreamTexCoords1 = 4,
    NpVertexStreamTexCoords2 = 5,
    NpVertexStreamTexCoords3 = 6,
    NpVertexStreamTexCoords4 = 7,
    NpVertexStreamTexCoords5 = 8,
    NpVertexStreamTexCoords6 = 9,
    NpVertexStreamTexCoords7 = 10,
    NpVertexStreamAttribute0 = 0,
    NpVertexStreamAttribute1 = 1,
    NpVertexStreamAttribute2 = 2,
    NpVertexStreamAttribute3 = 3,
    NpVertexStreamAttribute4 = 4,
    NpVertexStreamAttribute5 = 5,
    NpVertexStreamAttribute6 = 6,
    NpVertexStreamAttribute7 = 7,
    NpVertexStreamAttribute8 = 8,
    NpVertexStreamAttribute9 = 9,
    NpVertexStreamAttribute10 = 10,
    NpVertexStreamAttribute11 = 11,
    NpVertexStreamAttribute12 = 12,
    NpVertexStreamAttribute13 = 13,
    NpVertexStreamAttribute14 = 14,
    NpVertexStreamAttribute15 = 15,
    NpVertexStreamMin = 0,
    NpVertexStreamMax = 15
}
NpVertexStreamSemantic;

// these match the corresponding GLenums, no need to convert
typedef enum NpPrimitveType
{
    NpPrimitiveUnknown = -1,
    NpPrimitivePoints = 0,
    NpPrimitiveLines = 1,
    NpPrimitiveLineLoop = 2,
    NpPrimitiveLineStrip = 3,
    NpPrimitiveTriangles = 4,
    NpPrimitiveTriangleStrip = 5,
    NpPrimitiveTriangleFan = 6,
    NpPrimitiveQuads = 7,
    NpPrimitiveQuadStrip = 8
}
NpPrimitveType;

typedef enum NpOrthographicAlignment
{
    NpOrthographicAlignUnknown = -1,
    NpOrthographicAlignTopLeft = 0,
    NpOrthographicAlignTop = 1,
    NpOrthographicAlignTopRight = 2,
    NpOrthographicAlignRight = 3,
    NpOrthographicAlignBottomRight = 4,
    NpOrthographicAlignBottom = 5,
    NpOrthographicAlignBottomLeft = 6,
    NpOrthographicAlignLeft = 7
}
NpOrthographicAlignment;

GLenum getGLTextureDataFormat(const NpTextureDataFormat dataFormat);
GLenum getGLTexturePixelFormat(const NpTexturePixelFormat pixelFormat, const bool normalized);
GLint  getGLTextureWrap(const NpTextureWrap textureWrap);
GLint  getGLTextureInternalFormat(const NpTextureDataFormat dataFormat,
            const NpTexturePixelFormat pixelFormat, const bool sRGBSupport,
            GLenum * glDataFormat, GLenum * glPixelFormat);


GLenum getGLComparisonFunction(const NpComparisonFunction comparisonFunction);
GLenum getGLCullface(const NpCullface cullface);
GLenum getGLPolygonFillMode(const NpPolygonFillMode polygonFillMode);

/*
GLenum getGLRenderBufferInternalFormat(const NpRenderTargetType Type,
            const NpRenderBufferPixelFormat PixelFormat,
            const NpRenderBufferDataFormat DataFormat);
*/

GLenum getGLBufferUsage(const NpBufferDataUpdateRate UpdateRate,
            const NpBufferDataUsage Usage);

GLenum getCPUBufferType(const NpCPUBufferType Type);
GLenum getGLBufferType(const NpBufferObjectType Type);
GLenum getGLBufferDataFormat(const NpBufferDataFormat DataFormat);
size_t numberOfBytesForDataFormat(const NpBufferDataFormat DataFormat);

#endif


