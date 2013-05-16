#import "Core/Basics/NpBasics.h"
#import "Core/Math/NpMath.h"
#import "fftw3.h"

typedef struct ODSpectrumSettings
{
    IVector2 resolution;
    Vector2  size;
    Vector2  windDirection;
}
ODSpectrumSettings;

typedef struct OdFrequencySpectrumDouble
{
    double timestamp;
    IVector2 resolution;
    fftw_complex * waveSpectrum;
    fftw_complex * gradientX;
    fftw_complex * gradientZ;
}
OdFrequencySpectrumDouble;

typedef struct OdFrequencySpectrumFloat
{
    float timestamp;
    IVector2 resolution;
    fftwf_complex * waveSpectrum;
    fftwf_complex * gradientX;
    fftwf_complex * gradientZ;
}
OdFrequencySpectrumFloat;

@protocol ODPFrequencySpectrumGenerationDouble

- (OdFrequencySpectrumDouble) generateDoubleFrequencySpectrum:(const ODSpectrumSettings)settings
                                            atTime:(const double)time
                                                  ;

- (OdFrequencySpectrumDouble) generateDoubleFrequencySpectrumHC:(const ODSpectrumSettings)settings
                                              atTime:(const double)time
                                                    ;

@end

@protocol ODPFrequencySpectrumGenerationFloat

- (OdFrequencySpectrumFloat) generateFloatFrequencySpectrum:(const ODSpectrumSettings)settings
                                            atTime:(const float)time
                                                  ;

- (OdFrequencySpectrumFloat) generateFloatFrequencySpectrumHC:(const ODSpectrumSettings)settings
                                              atTime:(const float)time
                                                    ;

@end
