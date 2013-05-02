#import "fftw3.h"
#import "Core/NPObject/NPObject.h"
#import "ODGaussianRNG.h"
#import "ODPFrequencySpectrumGeneration.h"

@interface ODPhillipsSpectrumFloat : NPObject < ODPFrequencySpectrumGenerationFloat >
{
    fftwf_complex * H0;
    OdGaussianRng * gaussianRNG;
    ODSpectrumSettings lastSettings;
    ODSpectrumSettings currentSettings;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (void) generateH0;
- (OdFrequencySpectrumFloat) generateHAtTime:(const float)time;
- (OdFrequencySpectrumFloat) generateTimeIndependentH;
- (OdFrequencySpectrumFloat) generateHHCAtTime:(const float)time;
- (OdFrequencySpectrumFloat) generateTimeIndependentHHC;

@end
