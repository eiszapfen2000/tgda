#import "fftw3.h"
#import "Core/NPObject/NPObject.h"
#import "OBPFrequencySpectrumGeneration.h"

#define PHILLIPS_CONSTANT       0.0081

@interface OBPhillipsSpectrum : NPObject < OBPFrequencySpectrumGeneration >
{
    double alpha;

    IVector2 resolution;
    Vector2 size;
    Vector2 windDirection;

    id gaussianRNG;

    BOOL needsUpdate;
    double lastTime;

    fftw_complex * H0;
    fftw_complex * frequencySpectrum;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (double) omegaForK:(Vector2 *)k;
- (double) indexToKx:(int32_t)index;
- (double) indexToKy:(int32_t)index;

@end
