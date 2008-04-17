#import "Core/Basics/NpBasics.h"
#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"

#import "fftw3.h"

@class NPRandomNumberGenerator;
@class NPGaussianRandomNumberGenerator;

@interface TOOceanSurfaceGenerator : NPObject
{
    // Resolution
    Int resX, resY;

    // Size
    Int length, width;

    NPRandomNumberGenerator * generatorOne;
    NPRandomNumberGenerator * generatorTwo;
	//Gaussian RandomNumber Generator
	NPGaussianRandomNumberGenerator * gaussianGenerator;

    Vector3 * pointArray;

    long * pointIndexArray;

    Real * h;

}

- init
    :(Int)newResX
    :(Int)newResY
    :(Int)newLength
    :(Int)newWidth
    ;

- (void) setup;

- (Int)resX;
- (void) setResX:(Int)newResX;
- (Int)resY;
- (void) setResY:(Int)newResY;
- (Int)length;
- (void) setLength:(Int)newLength;
- (Int)width;
- (void) setWidth:(Int)newWidth;


- (Real) kToOmega:(Vector2 *)k;

- (Real) indexToK:(Int)index;

@end

@interface TOOceanSurfaceGeneratorPhillips : TOOceanSurfaceGenerator
{
    Real U10;

    Vector2 windDirection;

    Real alpha;

    fftw_complex * H0;
	fftw_complex * H;
}

- init
    :(Int)newResX
    :(Int)newResY
    :(Int)newLength
    :(Int)newWidth
    :(Vector2)newWind
    ;

- (void) setupH0;

@end

@interface TOOceanSurfaceGeneratorSWOP : TOOceanSurfaceGenerator
{
    Real U10;

    Real L, X;
}

- init
    :(Int)newResX
    :(Int)newResY
    :(Int)newLength
    :(Int)newWidth
    :(Real)newU10
    ;

@end

@interface TOOceanSurfaceGeneratorFreqBasedWaveSpectrum : TOOceanSurfaceGenerator

- (Real) getAmplitudeAtK:(Vector2 *)k;

@end

@interface TOOceanSurfaceGeneratorPiersmos : TOOceanSurfaceGeneratorFreqBasedWaveSpectrum
{
    Real U10;
}

- init
    :(Int)newResX
    :(Int)newResY
    :(Int)newLength
    :(Int)newWidth
    :(Real)newU10
    ;

@end

@interface TOOceanSurfaceJONSWAP : TOOceanSurfaceGeneratorPiersmos
{
    Real fetch;
}

- init
    :(Int)newResX
    :(Int)newResY
    :(Int)newLength
    :(Int)newWidth
    :(Real)newU10
    :(Real)newFetch
    ;

@end
