#import "fftw3.h"
#import "Core/NPObject/NPObject.h"
#import "ODPFrequencySpectrumGeneration.h"

#define PHILLIPS_CONSTANT       0.0081

@interface ODPhillipsSpectrum : NPObject < ODPFrequencySpectrumGeneration >
{
    double alpha;

    IVector2 resolution;
    Vector2 size;
    Vector2 windDirection;

    BOOL needsUpdate;
    double lastTime;

    fftw_complex * H0;
    fftw_complex * frequencySpectrum;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

@end
