#include <fftw3.h>

#import <Foundation/Foundation.h>

#include "Math/FVector.h"
#include "Math/Vector.h"
#include "Math/Matrix.h"

@interface TOOceanSurface : NSObject
{
    // Resolution
    UInt32 mResX, mResY;

    // Size
    UInt32 mLength, mWidth;

    Vector3 * mPointArray;

    long * mPointIndexArray;

    Real * mh;

}

- init
    : (UInt32) resX
    : (UInt32) resY
    : (UInt32) length
    : (UInt32) width
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

    fftw_complex mH0, mH;
}

- init
    : (UInt32) resX
    : (UInt32) resY
    : (UInt32) length
    : (UInt32) width
    : (Vector2) wind
    ;

@end

@interface TOOceanSurfaceSWOP : TOOceanSurface
{
    Real U10;

    Real L, X;
}

- init
    : (UInt32) resX
    : (UInt32) resY
    : (UInt32) length
    : (UInt32) width
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
    : (UInt32) resX
    : (UInt32) resY
    : (UInt32) length
    : (UInt32) width
    : (Real) U10
    ;

@end

@interface TOOceanSurfaceJONSWAP : TOOceanSurfacePiersmos
{
    Real fetch;
}

- init
    : (UInt32) resX
    : (UInt32) resY
    : (UInt32) length
    : (UInt32) width
    : (Real) U10
    : (Real) fetch
    ;

@end
