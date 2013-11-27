#import "Core/Basics/NpBasics.h"
#import "Core/Math/NpMath.h"
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
    Vector2  size;
}
ODSpectrumGeometry;

typedef struct ODPhillipsGeneratorSettings
{
    ODSpectrumGenerator generator;
    Vector2  windDirection;
    double   windSpeed;
    double   dampening;
}
ODPhillipsGeneratorSettings;

typedef struct ODUnifiedGeneratorSettings
{
    ODSpectrumGenerator generator;
    double   U10;
    double   Omega;
}
ODUnifiedGeneratorSettings;

typedef struct ODGeneratorSettings
{
    ODSpectrumGenerator generatorType;
    union
    {
        ODPhillipsGeneratorSettings phillips;
        ODUnifiedGeneratorSettings  unified;
    }
    base;
}
ODGeneratorSettings;

typedef struct OdFrequencySpectrumDouble
{
    double timestamp;
    IVector2 geometryResolution;
    IVector2 gradientResolution;
    Vector2  size;
    fftw_complex * waveSpectrum;
    fftw_complex * gradientX;
    fftw_complex * gradientZ;
    fftw_complex * displacementX;
    fftw_complex * displacementZ;
}
OdFrequencySpectrumDouble;

typedef struct OdFrequencySpectrumFloat
{
    float timestamp;
    IVector2 geometryResolution;
    IVector2 gradientResolution;
    Vector2 size;
    float * baseSpectrum; // zero frequency at center
    float maxMeanSlopeVariance;
    float effectiveMeanSlopeVariance;
    fftwf_complex * waveSpectrum; // zeros frequency upper left
    fftwf_complex * gradientX;
    fftwf_complex * gradientZ;
    fftwf_complex * displacementX;
    fftwf_complex * displacementZ;
}
OdFrequencySpectrumFloat;

/*
@protocol ODPFrequencySpectrumGenerationDouble

- (OdFrequencySpectrumDouble) generateDoubleFrequencySpectrum:(const ODSpectrumSettings)settings
                                            atTime:(const double)time
                                                  ;

- (OdFrequencySpectrumDouble) generateDoubleFrequencySpectrumHC:(const ODSpectrumSettings)settings
                                              atTime:(const double)time
                                                    ;

@end
*/

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
