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
- (fftwf_complex *) generateHAtTime:(const float)time;
- (fftwf_complex *) generateTimeIndependentH;
- (fftwf_complex *) generateHHCAtTime:(const float)time;
- (fftwf_complex *) generateTimeIndependentHHC;

@end
