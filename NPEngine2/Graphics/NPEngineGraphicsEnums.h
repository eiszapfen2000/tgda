#ifndef NPENGINEGRAPHICSENUMS_H_
#define NPENGINEGRAPHICSENUMS_H_

#include "GL/glew.h"

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

typedef enum NpTextureType
{
    NpTextureTypeUnknown = -1,
    NpTextureTypeTexture1D = 0,
    NpTextureTypeTexture2D = 1,
    NpTextureTypeTexture3D = 2,
    NpTextureTypeTextureCube = 3,
    NpTextureTypeTextureBuffer = 4
}
NpTextureType;

typedef enum NpTexture2DFilter
{
    NpTexture2DFilterNearest = 0,
    NpTexture2DFilterLinear = 1,
    NpTexture2DFilterLinearMipmapping = 2,
    NpTexture2DFilterTrilinear = 3
}
NpTexture2DFilter;

typedef enum NpTextureWrap
{
    NpTextureWrapToBorder = 0,
    NpTextureWrapToEdge = 1,
    NpTextureWrapRepeat = 2
}
NpTextureWrap;

typedef NpImagePixelFormat NpTexturePixelFormat;
typedef NpImageDataFormat  NpTextureDataFormat;

typedef enum NpShaderType
{
    NpShaderTypeUnknown = -1,
    NpShaderTypeVertex = 0,
    NpShaderTypeFragment = 1
}
NpShaderType;

typedef enum NpShaderVariableType
{
    NpShaderVariableTypeUnknown = -1,
    NpShaderVariableTypeTexture = 0,
    NpShaderVariableTypeSemantic = 1,
    NpShaderVariableTypeUniform = 2
}
NpShaderVariableType;

typedef enum NpEffectVariableType
{
    NpEffectVariableUnknown = -1,
    NpEffectVariableFloat,
    NpEffectVariableFloat2,
    NpEffectVariableFloat3,
    NpEffectVariableFloat4,
    NpEffectVariableInt,
    NpEffectVariableInt2,
    NpEffectVariableInt3,
    NpEffectVariableInt4,
    NpEffectVariableFMatrix2x2,
    NpEffectVariableFMatrix3x3,
    NpEffectVariableFMatrix4x4
}
NpEffectVariableType;

typedef enum NpComparisonFunction
{
    NpComparisonNever = 0,
    NpComparisonAlways,
    NpComparisonLess,
    NpComparisonLessEqual,
    NpComparisonEqual,
    NpComparisonGreaterEqual,
    NpComparisonGreater
}
NpComparisonFunction;

typedef enum NpBlendingMode
{
    NpBlendingAdditive = 0,
    NpBlendingAverage,
    NpBlendingSubtractive,
    NpBlendingMin,
    NpBlendingMax
}
NpBlendingMode;

typedef enum NpCullface
{
    NpCullfaceFront = 0,
    NpCullfaceBack
}
NpCullface;

typedef enum NpPolygonFillMode
{
    NpPolygonFillPoint = 0,
    NpPolygonFillLine,
    NpPolygonFillFace
}
NpPolygonFillMode;

GLenum getGLComparisonFunction(const NpComparisonFunction comparisonFunction);
GLenum getGLCullface(const NpCullface cullface);
GLenum getGLPolygonFillMode(const NpPolygonFillMode polygonFillMode);

#endif


