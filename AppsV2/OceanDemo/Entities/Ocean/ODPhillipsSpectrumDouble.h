#import "fftw3.h"
#import "Core/NPObject/NPObject.h"
#import "ODPFrequencySpectrumGeneration.h"

@interface ODPhillipsSpectrumDouble : NPObject < ODPFrequencySpectrumGenerationDouble >
{
    fftw_complex * H0;
    ODSpectrumSettings lastSettings;
    ODSpectrumSettings currentSettings;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (void) generateH0;
- (fftw_complex *) generateHAtTime:(const double)time;
- (fftw_complex *) generateTimeIndependentH;
- (fftw_complex *) generateHHCAtTime:(const double)time;
- (fftw_complex *) generateTimeIndependentHHC;

@end
