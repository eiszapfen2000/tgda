#import "fftw3.h"
#import "Core/NPObject/NPObject.h"
#import "ODPFrequencySpectrumGeneration.h"

@class ODPhillipsSpectrumFloat;

@interface ODFrequencySpectrum : NPObject < ODPFrequencySpectrumGenerationFloat >
{
    ODPhillipsSpectrumFloat * floatGenerator;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

@end
