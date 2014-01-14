#import "fftw3.h"
#import "Core/NPObject/NPObject.h"
#import "ODGaussianRNG.h"
#import "ODPFrequencySpectrumGeneration.h"

@interface ODFrequencySpectrumFloat : NPObject < ODPFrequencySpectrumGenerationFloat >
{
    fftwf_complex * H0;
    float * baseSpectrum;
    double * randomNumbers;
    IVector2 H0Resolution;
    uint32_t H0Lods;
    OdGaussianRng * gaussianRNG;
    float maxMeanSlopeVariance;
    float effectiveMeanSlopeVariance;
    OdSpectrumGeometry lastGeometry;
    OdSpectrumGeometry currentGeometry;
    ODGeneratorSettings lastGeneratorSettings;
    ODGeneratorSettings currentGeneratorSettings;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (OdFrequencySpectrumFloat) generateHAtTime:(const float)time;
- (OdFrequencySpectrumFloat) generateTimeIndependentH;
- (OdFrequencySpectrumFloat) generateHHCAtTime:(const float)time;
- (OdFrequencySpectrumFloat) generateTimeIndependentHHC;

@end
