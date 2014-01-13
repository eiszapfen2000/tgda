#import "Core/Basics/NpBasics.h"
#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "fftw3.h"

typedef enum ODSpectrumGenerator
{
    Unknown  = -1,
    Phillips =  0,
    Unified  =  1
}
ODSpectrumGenerator;

typedef struct ODSpectrumGeometry
{
    IVector2 geometryResolution;
    IVector2 gradientResolution;
    uint32_t numberOfLods;
    Vector2 * sizes;
}
ODSpectrumGeometry;

void geometry_init_with_lods(ODSpectrumGeometry * geometry, uint32_t numberOfLods);
void geometry_clear(ODSpectrumGeometry * geometry);
bool geometry_copy(const ODSpectrumGeometry * source, ODSpectrumGeometry * target);

bool geometries_equal(const ODSpectrumGeometry * gOne, const ODSpectrumGeometry * gTwo);
bool geometries_equal_size(const ODSpectrumGeometry * gOne, const ODSpectrumGeometry * gTwo);
bool geometries_equal_resolution(const ODSpectrumGeometry * gOne, const ODSpectrumGeometry * gTwo);

ODSpectrumGeometry geometry_zero();
ODSpectrumGeometry geometry_max();

enum
{
    ODGeneratorOptionsHalfComplex  = (1 << 0),
    ODGeneratorOptionsHeights      = (1 << 1),
    ODGeneratorOptionsDisplacement = (1 << 2),
    ODGeneratorOptionsGradient     = (1 << 3),
    ODGeneratorOptionsDisplacementDerivatives = (1 << 4)
};

typedef NSUInteger ODGeneratorOptions;

typedef struct ODPhillipsGeneratorSettings
{
    Vector2  windDirection;
    double   windSpeed;
    double   dampening;
}
ODPhillipsGeneratorSettings;

typedef struct ODUnifiedGeneratorSettings
{
    double   U10;
    double   Omega;
}
ODUnifiedGeneratorSettings;

typedef struct ODGeneratorSettings
{
    ODSpectrumGenerator generatorType;
    ODGeneratorOptions  options;
    double spectrumScale;
    union
    {
        ODPhillipsGeneratorSettings phillips;
        ODUnifiedGeneratorSettings  unified;
    };
}
ODGeneratorSettings;

bool phillips_settings_equal(const ODPhillipsGeneratorSettings * pOne, const ODPhillipsGeneratorSettings * pTwo);
bool unified_settings_equal(const ODUnifiedGeneratorSettings * pOne, const ODUnifiedGeneratorSettings * pTwo);
bool generator_settings_equal(const ODGeneratorSettings * pOne, const ODGeneratorSettings * pTwo);

ODGeneratorSettings generator_settings_zero();
ODGeneratorSettings generator_settings_max();

typedef struct OdSpectrumDataFloat
{
    // zero frequency upper left
    fftwf_complex * height;
    fftwf_complex * gradient;
    fftwf_complex * displacement;
    fftwf_complex * displacementXdXdZ;
    fftwf_complex * displacementZdXdZ;
}
OdSpectrumDataFloat;

typedef struct OdSpectrumDataHCFloat
{
    // zero frequency upper left
    fftwf_complex * height;
    fftwf_complex * gradientX;
    fftwf_complex * gradientZ;
    fftwf_complex * displacementX;
    fftwf_complex * displacementZ;
    fftwf_complex * displacementXdX;
    fftwf_complex * displacementXdZ;
    fftwf_complex * displacementZdX;
    fftwf_complex * displacementZdZ;
}
OdSpectrumDataHCFloat;

typedef struct OdFrequencySpectrumFloat
{
    float timestamp;
    IVector2 geometryResolution;
    IVector2 gradientResolution;
    Vector2  size;

    // zero frequency at center
    float * baseSpectrum;
    float maxMeanSlopeVariance;
    float effectiveMeanSlopeVariance;

    union
    {
        OdSpectrumDataFloat   data;
        OdSpectrumDataHCFloat dataHC;
    };
}
OdFrequencySpectrumFloat;

@protocol ODPFrequencySpectrumGenerationFloat

- (OdFrequencySpectrumFloat)
    generateFloatSpectrumWithGeometry:(ODSpectrumGeometry)geometry
                            generator:(ODGeneratorSettings)generatorSettings
                               atTime:(const float)time
                 generateBaseGeometry:(BOOL)generateBaseGeometry
                                     ;

- (OdFrequencySpectrumFloat)
    generateFloatSpectrumHCWithGeometry:(ODSpectrumGeometry)geometry
                              generator:(ODGeneratorSettings)generatorSettings
                                 atTime:(const float)time
                   generateBaseGeometry:(BOOL)generateBaseGeometry
                                       ;

@end
