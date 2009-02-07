#import "Core/Basics/NpBasics.h"
#import "Core/Math/NpMath.h"
#import "fftw3.h"

@protocol OBPFrequencySpectrumGeneration

- (void) setSize:(IVector2 *)newSize;
- (void) setResolution:(IVector2 *)newResolution;
- (void) setWindDirection:(FVector2 *)newWindDirection;
- (void) setNumberOfThreads:(Int)newNumberOfThreads;
- (void) generateFrequencySpectrum;
- (fftwf_complex *) frequencySpectrum;

@end
