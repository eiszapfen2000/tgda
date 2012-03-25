#import "fftw3.h"
#import "Core/NPObject/NPObject.h"
#import "ODPFrequencySpectrumGeneration.h"

@class NPTimer;

@interface ODPhillipsSpectrumFloat : NPObject < ODPFrequencySpectrumGenerationFloat >
{
    fftwf_complex * H0;
    ODSpectrumSettings lastSettings;
    ODSpectrumSettings currentSettings;

    NPTimer * timer;
    float timings[8];
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (void) generateH0;
- (fftwf_complex *) generateHAtTime:(const float)time;
- (fftwf_complex *) generateTimeIndependentH;
- (fftwf_complex *) generateHHCAtTime:(const float)time;
- (fftwf_complex *) generateTimeIndependentHHC;

@end
