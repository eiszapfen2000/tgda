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

@protocol ODPFrequencySpectrumGeneration

- (fftw_complex *) generateFrequencySpectrum:(const ODSpectrumSettings)settings
                                      atTime:(const double)time
                                            ;

- (fftw_complex *) generateFrequencySpectrumHC:(const ODSpectrumSettings)settings
                                        atTime:(const double)time
                                              ;

@end
