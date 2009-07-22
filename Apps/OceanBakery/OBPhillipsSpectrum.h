#import "fftw3.h"
#import "Core/NPObject/NPObject.h"
#import "OBPFrequencySpectrumGeneration.h"

#define PHILLIPS_CONSTANT       0.0081

@interface OBPhillipsSpectrum : NPObject < OBPFrequencySpectrumGeneration >
{
    Float alpha;

    IVector2 * resolution;
    FVector2 * size;
    FVector2 * windDirection;

    id gaussianRNG;

    BOOL needsUpdate;
    Float lastTime;

    fftwf_complex * H0;
    fftwf_complex * frequencySpectrum;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (Float) omegaForK:(FVector2 *)k;
- (Float) indexToKx:(Int)index;
- (Float) indexToKy:(Int)index;

@end
