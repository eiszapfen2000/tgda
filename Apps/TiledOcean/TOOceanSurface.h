#import <Foundation/Foundation.h>
#import <fftw3.h>

#import "Core/Math/Vector.h"
#import "Core/RandomNumbers/NPGaussianRandomNumberGenerator.h"

@interface TOOceanSurface : NSObject
{
    // Resolution
    UInt64 mResX, mResY;

    // Size
    UInt64 mLength, mWidth;

	//Gaussian RandomNumber Generator
	NPGaussianRandomNumberGenerator * mGaussianGenerator;

    Vector3 * mPointArray;

    long * mPointIndexArray;

    Real * mh;

}

- init
    : (UInt64) resX
    : (UInt64) resY
    : (UInt64) length
    : (UInt64) width
    ;

- (Real) kToOmega
    : (Vector2 *) k
    ;

- (Real) indexToK
    : (Int) index
    ;

@end

@interface TOOceanSurfacePhillips : TOOceanSurface
{
    Real mU10;

    Vector2 mWindDirection;

    Real mAlpha;

    fftw_complex * mH0;
	fftw_complex * mH;
}

- init
    : (UInt64) resX
    : (UInt64) resY
    : (UInt64) length
    : (UInt64) width
    : (Vector2) wind
    ;

- (void) setupH0;

@end

@interface TOOceanSurfaceSWOP : TOOceanSurface
{
    Real U10;

    Real L, X;
}

- init
    : (UInt64) resX
    : (UInt64) resY
    : (UInt64) length
    : (UInt64) width
    : (Real) U10
    ;

@end

@interface TOOceanSurfaceFreqBasedWaveSpectrum : TOOceanSurface

- (Real) getAmplitudeAtK
    : (Vector2 *) k
    ;

@end

@interface TOOceanSurfacePiersmos : TOOceanSurfaceFreqBasedWaveSpectrum
{
    Real U10;
}

- init
    : (UInt64) resX
    : (UInt64) resY
    : (UInt64) length
    : (UInt64) width
    : (Real) U10
    ;

@end

@interface TOOceanSurfaceJONSWAP : TOOceanSurfacePiersmos
{
    Real fetch;
}

- init
    : (UInt64) resX
    : (UInt64) resY
    : (UInt64) length
    : (UInt64) width
    : (Real) U10
    : (Real) fetch
    ;

@end
