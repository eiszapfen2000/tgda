#import "TOOceanSurfaceGenerator.h"

#import "Core/RandomNumbers/NPRandomNumberGenerator.h"
#import "Core/RandomNumbers/NPGaussianRandomNumberGenerator.h"
#import "Core/RandomNumbers/NPRandomNumberGeneratorManager.h"
#import "Core/NPEngineCore.h"

@implementation TOOceanSurfaceGenerator

- (id) init
{
    return [ self initWithParent:nil ];
}

- (id) initWithParent:(NPObject *)newParent
{
    return [ self initWithName:@"TOOceanSurfaceGenerator" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    firstGenerators = [[ NSMutableDictionary alloc ] init ];
    secondGenerators = [[ NSMutableDictionary alloc ] init ];

    [ self createGeneratorsForDictionary:firstGenerators ];
    [ self createGeneratorsForDictionary:secondGenerators ];

    gaussianGenerator = [[[[ NPEngineCore instance ] randomNumberGeneratorManager ] gaussianGenerator ] retain ];

    [ self reset ];

    return self;
}

- (void) dealloc
{
    [ firstGenerators release ];
    [ secondGenerators release ];
    [ gaussianGenerator release ];

    [ super dealloc ];
}

- (void) reset
{
    resX = resY = -1;
    length = width = -1;

    [ gaussianGenerator setFirstGenerator:[firstGenerators objectForKey:NP_RNG_TT800] ];
    [ gaussianGenerator setSecondGenerator:[secondGenerators objectForKey:NP_RNG_TT800] ];
    
    ready = NO;
}

- (void) createGeneratorsForDictionary:(NSMutableDictionary *)dictionary
{
    [ dictionary setObject:[[[ NPEngineCore instance ] randomNumberGeneratorManager ] fixedParameterGeneratorWithRNGName:NP_RNG_TT800 ] forKey:NP_RNG_TT800 ];
    [ dictionary setObject:[[[ NPEngineCore instance ] randomNumberGeneratorManager ] fixedParameterGeneratorWithRNGName:NP_RNG_CTG ] forKey:NP_RNG_CTG ];
    [ dictionary setObject:[[[ NPEngineCore instance ] randomNumberGeneratorManager ] fixedParameterGeneratorWithRNGName:NP_RNG_MRG ] forKey:NP_RNG_MRG ];
    [ dictionary setObject:[[[ NPEngineCore instance ] randomNumberGeneratorManager ] fixedParameterGeneratorWithRNGName:NP_RNG_CMRG ] forKey:NP_RNG_CMRG ];
}

- (Int)resX
{
    return resX;
}

- (void) setResX:(Int)newResX
{
    resX = newResX;
}

- (Int)resY
{
    return resY;
}

- (void) setResY:(Int)newResY
{
    resY = newResY;
}

- (Int)length
{
    return length;
}

- (void) setLength:(Int)newLength
{
    length = newLength;
}

- (Int)width
{
    return width;
}

- (void) setWidth:(Int)newWidth
{
    width = newWidth;
}

- (Real) kToOmega:(Vector2 *)k
{
    Real klength = v2_v_length(k);

    if (klength == 0.0)
    {
        return 0.0;
    }

    return sqrt( EARTH_ACCELERATION * (MATH_2_MUL_PI / klength) );
}

- (Real) indexToK:(Int)index
{
    Real N = - ( resX / 2.0 );
    N += index;

    return N * ( MATH_2_MUL_PI / (length / 2.0) );
}

@end

@implementation TOOceanSurfaceGeneratorPhillips

- init
    :(Int)newResX
    :(Int)newResY
    :(Int)newLength
    :(Int)newWidth
    :(Vector2)newWind
{
    self = [ super init
              :newResX
              :newResY
              :newLength
              :newWidth ];

    windDirection = newWind;

    U10 = v2_v_length( &windDirection );
    alpha = PHILLIPS_CONSTANT;

    return self;
}

- (Real) getAmplitudeAt:(Vector2 *)k
{
    /* alpha is highly dependent on the the grid resolution, wind
    velocity and grid length. so this spectrum more or less is
    NOT only dependent on wind velocity, but also on the other
    parameters as well, AFAIK */

    Real ret, k2, u2, l;
    Vector2 knorm, wdirnorm;
    Real j;

    k2 = v2_v_square_length(k);

    v2_v_normalise_v(k,&knorm);
    v2_v_normalise_v(&windDirection,&wdirnorm);

    if ( k2 == 0.0 )
    {
        return 0.0;
    }

    u2 = v2_v_square_length(&windDirection);

    l = u2 / EARTH_ACCELERATION;

    j = 0.001 * l;

    ret  = PHILLIPS_CONSTANT;
    ret *= exp(-1.0 / (k2 * l * l)) / (k2 * k2);
    ret *= pow(v2_vv_dot_product(&knorm, &wdirnorm), 2.0);
    ret *= exp(-k2 * j * j);

    // empirical (don't you dare say random :) ) damping factor
    ret *= 0.1 * (1.0 / (Real) length);

    return ret;
}

- (void) setupH0
{
    Double xi_r, xi_i, a;
    Vector2 k;

	if ( !H0 )
	{
		H0 = (fftw_complex *)fftw_malloc(sizeof(fftw_complex)*resX*resY);
	}

    NSLog(@"start");

    for(Int i = 0; i < resX; i++)
    {
        for(Int j = 0; j < resY; j++)
        {
			xi_r = [ gaussianGenerator nextGaussianFPRandomNumber ];
			xi_i = [ gaussianGenerator nextGaussianFPRandomNumber ];

			//NSLog(@"%f %f",xi_r,xi_i);

            k.x = [ self indexToK : i ];
            k.y = [ self indexToK : j ];

            a = sqrt([ self getAmplitudeAt : &k ]);

			H0[j + resY * i][0] = MATH_1_DIV_SQRT_2 * xi_r * a;
			H0[j + resY * i][1] = MATH_1_DIV_SQRT_2 * xi_i * a;

			//NSLog(@"%e %e",mH0[j + mResY * i][0],mH0[j + mResY * i][1]);
        }
    }

    NSLog(@"stop");
}

@end

