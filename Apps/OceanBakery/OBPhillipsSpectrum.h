#import "fftw3.h"
#import "Core/NPObject/NPObject.h"
#import "OBPFrequencySpectrumGeneration.h"

#define PHILLIPS_CONSTANT       0.0081

@interface OBPhillipsSpectrum : NPObject < OBPFrequencySpectrumGeneration >
{
    IVector2 * resolution;
    IVector2 * size;
    Int numberOfThreads;
    id gaussianRNG;

    FVector2 * windDirection;
    Float alpha;
    fftwf_complex * H0;
    fftwf_complex * frequencySpectrum;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) setWindDirection:(FVector2 *)newWindDirection;
- (void) setGaussianRNG:(id)newGaussianRNG;

- (Float) omegaForK:(FVector2 *)k;
- (Float) indexToKx:(Int)index;
- (Float) indexToKy:(Int)index;

@end
