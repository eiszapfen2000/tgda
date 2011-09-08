#import "Core/Basics/NpBasics.h"
#import "Core/Math/NpMath.h"
#import "fftw3.h"

@protocol ODPFrequencySpectrumGeneration

- (void) setSize:(const Vector2)newSize;
- (void) setResolution:(const IVector2)newResolution;
- (void) setWindDirection:(const Vector2)newWindDirection;
- (void) generateTimeIndependentFrequencySpectrum;
- (void) generateFrequencySpectrumAtTime:(const double)time;
- (fftw_complex *) frequencySpectrum;

@end
