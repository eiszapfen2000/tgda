#import "fftw3.h"
#import "Core/NPObject/NPObject.h"
#import "ODPFrequencySpectrumGeneration.h"

@class ODFrequencySpectrumFloat;

@interface ODFrequencySpectrum : NPObject < ODPFrequencySpectrumGenerationFloat >
{
    ODFrequencySpectrumFloat * floatGenerator;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

@end
