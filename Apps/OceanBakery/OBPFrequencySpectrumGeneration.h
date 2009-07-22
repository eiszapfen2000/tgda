#import "Core/Basics/NpBasics.h"
#import "Core/Math/NpMath.h"
#import "fftw3.h"

@protocol OBPFrequencySpectrumGeneration

- (void) setSize:(FVector2 *)newSize;
- (void) setResolution:(IVector2 *)newResolution;
- (void) setWindDirection:(FVector2 *)newWindDirection;
- (void) setGaussianRNG:(id)newGaussianRNG;
- (void) generateTimeIndependentFrequencySpectrum;
- (void) generateFrequencySpectrumAtTime:(Float)time;
- (fftwf_complex *) frequencySpectrum;

@end
