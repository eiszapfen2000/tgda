#import "fftw3.h"
#import "Core/NPObject/NPObject.h"
#import "ODPFrequencySpectrumGeneration.h"

@class ODPhillipsSpectrumFloat;
@class ODPhillipsSpectrumDouble;

@interface ODPhillipsSpectrum : NPObject < ODPFrequencySpectrumGenerationDouble, ODPFrequencySpectrumGenerationFloat >
{
    ODPhillipsSpectrumFloat * floatGenerator;
    ODPhillipsSpectrumDouble * doubleGenerator;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

@end
