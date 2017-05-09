#import "Core/Basics/NpBasics.h"
#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "fftw3.h"

typedef struct OdSpectrumGeometry
{
    IVector2 geometryResolution;
    IVector2 gradientResolution;
    uint32_t numberOfLods;
    Vector2 * sizes;
}
OdSpectrumGeometry;

void geometry_init_with_resolutions_and_lods(OdSpectrumGeometry * geometry,
    int32_t geometryRes, int32_t gradientRes, uint32_t numberOfLods);

void geometry_set_max_size(OdSpectrumGeometry * geometry, double maxSize);

void geometry_set_size(OdSpectrumGeometry * geometry,
    uint32_t lodIndex, double lodSize);

void geometry_clear(OdSpectrumGeometry * geometry);
void geometry_copy(const OdSpectrumGeometry * source, OdSpectrumGeometry * target);

bool geometries_equal(const OdSpectrumGeometry * gOne, const OdSpectrumGeometry * gTwo);
bool geometries_equal_size(const OdSpectrumGeometry * gOne, const OdSpectrumGeometry * gTwo);
bool geometries_equal_resolution(const OdSpectrumGeometry * gOne, const OdSpectrumGeometry * gTwo);
bool geometries_equal_lods(const OdSpectrumGeometry * gOne, const OdSpectrumGeometry * gTwo);

OdSpectrumGeometry geometry_zero();
OdSpectrumGeometry geometry_max();

typedef enum OdSpectrumGenerator
{
    Unknown  = -1,
    PiersonMoskowitz = 0,
    JONSWAP = 1,
    Donelan = 2,
    Unified  = 3
}
OdSpectrumGenerator;

enum
{
    OdGeneratorOptionsHeights      = (1 << 0),
    OdGeneratorOptionsDisplacement = (1 << 1),
    OdGeneratorOptionsGradient     = (1 << 2),
    OdGeneratorOptionsDisplacementDerivatives = (1 << 3)
};

typedef NSUInteger OdGeneratorOptions;

typedef struct OdPiersonMoskowitzGeneratorSettings
{
    double U10;
}
OdPiersonMoskowitzGeneratorSettings;

typedef struct OdJONSWAPGeneratorSettings
{
    double U10;
    double fetch;
}
OdJONSWAPGeneratorSettings;

typedef struct OdDonelanGeneratorSettings
{
    double U10;
    double fetch;
}
OdDonelanGeneratorSettings;

typedef struct OdUnifiedGeneratorSettings
{
    double U10;
    double fetch;
}
OdUnifiedGeneratorSettings;


typedef struct OdGeneratorSettings
{
    OdSpectrumGenerator generatorType;
    OdGeneratorOptions  options;
    double spectrumScale;
    union
    {
        OdPiersonMoskowitzGeneratorSettings piersonmoskowitz;
        OdJONSWAPGeneratorSettings jonswap;
        OdDonelanGeneratorSettings donelan;
        OdUnifiedGeneratorSettings unified;
    };
}
OdGeneratorSettings;

bool piersonmoskowitz_settings_equal(const OdPiersonMoskowitzGeneratorSettings * pOne, const OdPiersonMoskowitzGeneratorSettings * pTwo);
bool jonswap_settings_equal(const OdJONSWAPGeneratorSettings * pOne, const OdJONSWAPGeneratorSettings * pTwo);
bool donelan_settings_equal(const OdDonelanGeneratorSettings * pOne, const OdDonelanGeneratorSettings * pTwo);
bool unified_settings_equal(const OdUnifiedGeneratorSettings * pOne, const OdUnifiedGeneratorSettings * pTwo);
bool generator_settings_equal(const OdGeneratorSettings * pOne, const OdGeneratorSettings * pTwo);

OdGeneratorSettings generator_settings_zero();
OdGeneratorSettings generator_settings_max();

#define NUMBER_OF_GEN_TIMINGS 3

#define H0_GEN_TIMING   0
#define H_GEN_TIMING    1
#define QSWAP_TIMING    2

typedef struct OdFrequencySpectrumFloat
{
    // corresponds to the time parameter used in
    // the ODPFrequencySpectrumGenerationFloat protocol
    float timestamp;

    // geometry
    OdSpectrumGeometry geometry;

    // options this was created with
    OdGeneratorOptions  options;

    // variance related stuff
    // zero frequency at center
    float * baseSpectrum;
    float maxMeanSlopeVariance;
    float effectiveMeanSlopeVariance;

    // actual data
    fftwf_complex * height;
    fftwf_complex * gradient;
    fftwf_complex * displacement;
    fftwf_complex * displacementXdXdZ;
    fftwf_complex * displacementZdXdZ;

    double timings[NUMBER_OF_GEN_TIMINGS];
}
OdFrequencySpectrumFloat;

void frequency_spectrum_init_with_geometry_and_options(
    OdFrequencySpectrumFloat * spectrum,
    const OdSpectrumGeometry * const geometry,
    OdGeneratorOptions options
    );

void frequency_spectrum_clear(OdFrequencySpectrumFloat * spectrum);

OdFrequencySpectrumFloat frequency_spectrum_zero();

@protocol ODPFrequencySpectrumGenerationFloat

- (OdFrequencySpectrumFloat)
    generateFloatSpectrumWithGeometry:(OdSpectrumGeometry)geometry
                            generator:(OdGeneratorSettings)generatorSettings
                               atTime:(float)time
                 generateBaseGeometry:(BOOL)generateBaseGeometry
                                     ;

@end
