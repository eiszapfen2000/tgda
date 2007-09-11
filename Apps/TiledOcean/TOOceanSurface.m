#include "Math/Constants.h"

#import "TOOceanSurface.h"

@implementation TOOceanSurface

- init
    : (UInt32) resX
    : (UInt32) resY
    : (UInt32) length
    : (UInt32) width
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
    : (UInt32) resX
    : (UInt32) resY
    : (UInt32) length
    : (UInt32) width
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

    //g2d_v_norm_v(k, &knorm);
    //g2d_v_norm_v(&wdir, &wdirnorm);

    if ( k2 == 0.0 )
    {
        return 0.0;
    }

    u2 = v2_v_square_length(&mWindDirection);
    //u2 = g2d_v_sqrlen(&wdir);

    l = u2 / EARTH_ACCELERATION;

    j = 0.001 * l;

    ret  = PHILLIPS_CONSTANT;
    ret *= exp(-1.0 / (k2 * l * l)) / (k2 * k2);
    ret *= pow(v2_vv_dot_product(&knorm, &wdirnorm), 2.0);
    //ret *= pow(g2d_vv_dot(&knorm, &wdirnorm), 2.0);

    ret *= exp(-k2 * j * j);

    // empirical (don't you dare say random :) ) damping factor
    ret *= 0.1 * (1.0 / (Real) mLength);

    return ret;
}

@end

