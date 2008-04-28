#import "Core/Basics/NpBasics.h"
#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"

#import "fftw3.h"

#define TO_FSG_PHILLIPS     @"PHILLIPS"
#define TO_FSG_SWOP         @"SWOP"
#define TO_FSG_PIERSMOS     @"PIERSMOS"
#define TO_FSG_JONSWOP      @"JONSWOP"


@class NPGaussianRandomNumberGenerator;

@interface TOFrequencySpectrumGenerator : NPObject
{
    Int resX, resY;
    Int width, length;

    NPGaussianRandomNumberGenerator * gaussianRNG;

    fftw_complex * frequencySpectrum;

    BOOL resOK;
    BOOL sizeOK;
    BOOL rngOK;
}

- (id) init;
- (id) initWithParent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (void) reset;

- (BOOL) ready;

- (void) setResX:(Int)newResX;
- (void) setResY:(Int)newResY;
- (void) setWidth:(Int)newWidth;
- (void) setLength:(Int)newLength;

- (void) setGaussianRNG:(NPGaussianRandomNumberGenerator *)newGaussianRNG;

- (void) resetFrequencySpectrum;
- (fftw_complex *) frequencySpectrum;

@end

@interface TOPhillipsFrequencySpectrumGenerator : TOFrequencySpectrumGenerator
{
    Vector2 windDirection;

    Double alpha;

    fftw_complex * H0;
	fftw_complex * H;

    BOOL windOK;
}

- (id) init;
- (id) initWithParent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (void) resetH0;
- (void) reset;

- (void) setWindDirection:(Vector2 *)newWindDirection;

- (Double) indexToKx:(Int)index;
- (Double) indexToKy:(Int)index;

- (void) generateH0;
- (void) generateH;
- (void) generateFrequencySpectrum;

@end

@interface TOSWOPFrequencySpectrumGenerator : TOFrequencySpectrumGenerator
{
    Double U10;
    Double L, X;
}

- (id) init;
- (id) initWithParent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (void) generateFrequencySpectrum;

@end

@interface TOPiersmosFrequencySpectrumGenerator : TOFrequencySpectrumGenerator
{
    Double U10;
}

- (id) init;
- (id) initWithParent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (void) generateFrequencySpectrum;

@end

@interface TOJONSWOPFrequencySpectrumGenerator : TOFrequencySpectrumGenerator
{
    Double U10;
    Double fetch;
}

- (id) init;
- (id) initWithParent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (void) generateFrequencySpectrum;

@end
