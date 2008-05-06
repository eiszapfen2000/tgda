#import "Core/Basics/NpBasics.h"
#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"

#import "fftw3.h"

#define TO_FSG_PHILLIPS     @"PHILLIPS"
#define TO_FSG_SWOP         @"SWOP"
#define TO_FSG_PIERSMOS     @"PIERSMOS"
#define TO_FSG_JONSWOP      @"JONSWOP"

#define PHILLIPS_CONSTANT       0.0081
#define SWOP_CONSTANT           0.763


@class NPGaussianRandomNumberGenerator;

@interface TOFrequencySpectrumGenerator : NPObject
{
    Int resX, resY;
    Int width, length;
    Int numberOfThreads;

    NPGaussianRandomNumberGenerator * gaussianRNG;

    fftw_complex * frequencySpectrum;

    BOOL resOK;
    BOOL sizeOK;
    BOOL rngOK;
    BOOL threadsOK;
}

- (id) init;
- (id) initWithParent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (void) reset;

- (BOOL) ready;

- (Int) resX;
- (void) setResX:(Int)newResX;
- (Int) resY;
- (void) setResY:(Int)newResY;
- (void) setWidth:(Int)newWidth;
- (void) setLength:(Int)newLength;
- (void) setNumberOfThreads:(Int)newNumberOfThreads;

- (void) setGaussianRNG:(NPGaussianRandomNumberGenerator *)newGaussianRNG;

- (void) resetFrequencySpectrum;
- (fftw_complex *) frequencySpectrum;

@end

@interface TOPhillipsFrequencySpectrumGenerator : TOFrequencySpectrumGenerator
{
    Vector2 windDirection;

    Double alpha;

    fftw_complex * H0;

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

    BOOL LXOK;
    BOOL U10OK;
}

- (id) init;
- (id) initWithParent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (void) setU10:(Double)newU10;
- (void) setL:(Double)newL;
- (void) setX:(Double)newX;
- (void) setWindDirection:(Vector2 *)newWindDirection;

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
