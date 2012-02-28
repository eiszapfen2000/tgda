#import "fftw3.h"
#import "Core/NPObject/NPObject.h"
#import "ODPFrequencySpectrumGeneration.h"

#define PHILLIPS_CONSTANT       0.0081

@interface ODPhillipsSpectrum : NPObject < ODPFrequencySpectrumGeneration >
{
    fftw_complex * H0;
    ODSpectrumSettings lastSettings;
    ODSpectrumSettings currentSettings;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

@end
