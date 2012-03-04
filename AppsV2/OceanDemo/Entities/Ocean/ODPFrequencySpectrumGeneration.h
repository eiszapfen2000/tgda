#import "Core/Basics/NpBasics.h"
#import "Core/Math/NpMath.h"
#import "fftw3.h"

typedef struct ODSpectrumSettings
{
    IVector2 resolution;
    Vector2 size;
    Vector2 windDirection;    
}
ODSpectrumSettings;

@protocol ODPFrequencySpectrumGenerationDouble

- (fftw_complex *) generateDoubleFrequencySpectrum:(const ODSpectrumSettings)settings
                                            atTime:(const double)time
                                                  ;

- (fftw_complex *) generateDoubleFrequencySpectrumHC:(const ODSpectrumSettings)settings
                                              atTime:(const double)time
                                                    ;

@end

@protocol ODPFrequencySpectrumGenerationFloat

- (fftwf_complex *) generateFloatFrequencySpectrum:(const ODSpectrumSettings)settings
                                            atTime:(const float)time
                                                  ;

- (fftwf_complex *) generateFloatFrequencySpectrumHC:(const ODSpectrumSettings)settings
                                              atTime:(const float)time
                                                    ;

@end
