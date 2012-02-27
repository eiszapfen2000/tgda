#include <math.h>
#include "Core/Basics/NpTypes.h"
#include "ODGaussianRNG.h"

static struct prng * tt800   = NULL;
static struct prng * ctg     = NULL;
static struct prng * mrg     = NULL;
static struct prng * cmrg    = NULL;
static struct prng * mt19937 = NULL;

static int32_t use_last_value = 0;
static double first_value  = 0.0;
static double second_value = 0.0;

void odgaussianrng_initialise()
{
    tt800   = prng_new("tt800");
    ctg     = prng_new("ctg");
    mrg     = prng_new("mrg");
    cmrg    = prng_new("cmrg");
    mt19937 = prng_new("mt19937(0)");
}

void odgaussianrng_reset()
{
    prng_reset(mt19937);
    prng_reset(cmrg);
    prng_reset(mrg);
    prng_reset(ctg);
    prng_reset(tt800);
}

void odgaussianrng_shutdown()
{
    odgaussianrng_reset();

    prng_free(mt19937);
    prng_free(cmrg);
    prng_free(mrg);
    prng_free(ctg);
    prng_free(tt800);
}

double gaussian_fprandomnumber()
{
    double x1, x2, w;

    if ( use_last_value )
    {
	    first_value = second_value;
	    use_last_value = 0;
    }
    else
    {
	    do
	    {
		    x1 = 2.0 * prng_get_next(mt19937) - 1.0;
		    x2 = 2.0 * prng_get_next(mt19937) - 1.0;

		    w = x1 * x1 + x2 * x2;
	    }
	    while ( w >= 1.0 || w == 0.0 );

	    w = sqrt( (-2.0 * log( w ) ) / w );

	    first_value  = x1 * w;
	    second_value = x2 * w;

	    use_last_value = 1; 
    }

    return first_value;
}

double gaussian_ss_fprandomnumber(const double mean, const double variance)
{
    double x1, x2, w;

    if ( use_last_value )
    {
	    first_value = second_value;
	    use_last_value = 0;
    }
    else
    {
	    do
	    {
		    x1 = 2.0 * prng_get_next(mt19937) - 1.0;
		    x2 = 2.0 * prng_get_next(mt19937) - 1.0;

		    w = x1 * x1 + x2 * x2;
	    }
	    while ( w >= 1.0 || w == 0.0 );

	    w = sqrt( (-2.0 * log( w ) ) / w );

	    first_value  = x1 * w;
	    second_value = x2 * w;

	    use_last_value = 1; 
    }

    return mean + first_value * variance;    
}

