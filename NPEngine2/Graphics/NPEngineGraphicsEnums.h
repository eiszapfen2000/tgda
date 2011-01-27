

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
