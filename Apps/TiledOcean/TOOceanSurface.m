#import "TOOceanSurface.h"

#import "RandomNumbers/NPGaussianRandomNumberGenerator.h"

#include "Math/Constants.h"

@implementation TOOceanSurface

- init
    : (UInt64) resX
    : (UInt64) resY
    : (UInt64) length
    : (UInt64) width
{
    self = [ super init ];

    mResX = resX;
    mResY = resY;
    mLength = length;
    mWidth = width;

    return self;
}

- (Real) kToOmega
    : (Vector2 *) k
{
    Real length = v2_v_length(k);

    if (length == 0.0)
    {
        return 0.0;
    }

    return sqrt( EARTH_ACCELERATION * (MATH_2_MUL_PI / length) );
}

- (Real) indexToK
    : (Int) index
{
    Real N = - ( mResX / 2.0 );
    N += index;

    return N * ( MATH_2_MUL_PI / (mLength / 2.0) );
}

@end

@implementation TOOceanSurfacePhillips

- init
    : (UInt64) resX
    : (UInt64) resY
    : (UInt64) length
    : (UInt64) width
    : (Vector2) wind
{
    self = [ super init
              : resX
              : resY
              : length
              : width ];

    mWindDirection = wind;

    mU10 = v2_v_length( &mWindDirection );
    mAlpha = PHILLIPS_CONSTANT;

    return self;
}

- (Real) getAmplitudeAt
    : (Vector2 *) k
{
    /* alpha is highly dependent on the the grid resolution, wind
    velocity and grid length. so this spectrum more or less is
    NOT only dependent on wind velocity, but also on the other
    parameters as well, AFAIK */

    Real ret, k2, u2, l;
    Vector2 knorm, wdirnorm;
    Real j;

    k2 = v2_v_square_length(k);

    v2_v_normalize_v(k,&knorm);
    v2_v_normalize_v(&mWindDirection,&wdirnorm);

    if ( k2 == 0.0 )
    {
        return 0.0;
    }

    u2 = v2_v_square_length(&mWindDirection);

    l = u2 / EARTH_ACCELERATION;

    j = 0.001 * l;

    ret  = PHILLIPS_CONSTANT;
    ret *= exp(-1.0 / (k2 * l * l)) / (k2 * k2);
    ret *= pow(v2_vv_dot_product(&knorm, &wdirnorm), 2.0);
    ret *= exp(-k2 * j * j);

    // empirical (don't you dare say random :) ) damping factor
    ret *= 0.1 * (1.0 / (Real) mLength);

    return ret;
}

- (void) setupH0
{
    Double xi_r, xi_i, a;
    Vector2 k;

	if ( !mH0 )
	{
		mH0 = (fftw_complex *)fftw_malloc(sizeof(fftw_complex)*mResX*mResY);
	}

	NPGaussianRandomNumberGenerator * gaussian = [ [ NPGaussianRandomNumberGenerator alloc ] init ];

    NSLog(@"start");

    for(UInt64 i = 0; i < mResX; i++)
    {
        for(UInt64 j = 0; j < mResY; j++)
        {
			xi_r = [ gaussian nextGaussianFPRandomNumber ];
			xi_i = [ gaussian nextGaussianFPRandomNumber ];

			//NSLog(@"%f %f",xi_r,xi_i);

            k.x = [ self indexToK : i ];
            k.y = [ self indexToK : j ];

            a = sqrt([ self getAmplitudeAt : &k ]);

			mH0[j + mResY * i][0] = MATH_1_DIV_SQRT_2 * xi_r * a;
			mH0[j + mResY * i][1] = MATH_1_DIV_SQRT_2 * xi_i * a;

			//NSLog(@"%e %e",mH0[j + mResY * i][0],mH0[j + mResY * i][1]);
        }
    }

    NSLog(@"stop");

    [ gaussian release ];
}

@end

