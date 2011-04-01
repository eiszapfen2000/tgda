#import "fftw3.h"
#import "Core/NPObject/NPObject.h"
#import "OBPFrequencySpectrumGeneration.h"

#define PHILLIPS_CONSTANT       0.0081

@interface OBPhillipsSpectrum : NPObject < OBPFrequencySpectrumGeneration >
{
    Float alpha;

    IVector2 resolution;
    FVector2 size;
    FVector2 windDirection;

    id gaussianRNG;

    BOOL needsUpdate;
    float lastTime;

    fftwf_complex * H0;
    fftwf_complex * frequencySpectrum;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (float) omegaForK:(FVector2 *)k;
- (float) indexToKx:(int32_t)index;
- (float) indexToKy:(int32_t)index;

@end
