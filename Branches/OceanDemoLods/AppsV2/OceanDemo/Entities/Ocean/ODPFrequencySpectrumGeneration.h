#import "Core/Basics/NpBasics.h"
#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "fftw3.h"

typedef enum ODSpectrumGenerator
{
    Phillips = 0,
    Unified  = 1
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

bool geometry_copy(const ODSpectrumGeometry * source, ODSpectrumGeometry * target);

bool geometries_equal(const ODSpectrumGeometry * gOne, const ODSpectrumGeometry * gTwo);
bool geometries_equal_size(const ODSpectrumGeometry * gOne, const ODSpectrumGeometry * gTwo);
bool geometries_equal_resolution(const ODSpectrumGeometry * gOne, const ODSpectrumGeometry * gTwo);

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

typedef struct OdFrequencySpectrumFloat
{
    float timestamp;
    IVector2 geometryResolution;
    IVector2 gradientResolution;
    Vector2 size;
    float * baseSpectrum; // zero frequency at center
    float maxMeanSlopeVariance;
    float effectiveMeanSlopeVariance;
    fftwf_complex * height; // zero frequency upper left
    fftwf_complex * gradientX;
    fftwf_complex * gradientZ;
    fftwf_complex * gradient;
    fftwf_complex * displacementX;
    fftwf_complex * displacementZ;
    fftwf_complex * displacement;
    fftwf_complex * displacementXdXdZ;
    fftwf_complex * displacementZdXdZ;
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
