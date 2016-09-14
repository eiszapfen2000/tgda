#include <assert.h>
#include <math.h>
#include <time.h>
#include "Core/Basics/NpTypes.h"
#include "Core/Basics/NpMemory.h"
#include "ODGaussianRNG.h"

#ifndef MAX
#define MAX(a,b) ((a) > (b) ? a : b)
#endif

#ifndef MIN
#define MIN(a,b) ((a) < (b) ? a : b)
#endif

static char * rng_names[] = {"tt800", "ctg", "mrg", "cmrg", "mt19937(0)"};

OdGaussianRng * odgaussianrng_alloc(void)
{
    OdGaussianRng * grng = ALLOC(OdGaussianRng);
    memset(grng, 0, sizeof(OdGaussianRng));

    return grng;
}

OdGaussianRng * odgaussianrng_alloc_init(void)
{
    OdGaussianRng * grng = ALLOC(OdGaussianRng);
    memset(grng, 0, sizeof(OdGaussianRng));
    grng->rng = prng_new(rng_names[OdGaussianRngMT19937]);

    return grng;
}

OdGaussianRng * odgaussianrng_alloc_init_with_type(OdGaussianRngType type)
{
    assert( type >= OdGaussianRngTypeMin && type <= OdGaussianRngTypeMax );

    OdGaussianRng * grng = ALLOC(OdGaussianRng);
    memset(grng, 0, sizeof(OdGaussianRng));
    grng->rng = prng_new(rng_names[type]);

    return grng;
}

void odgaussianrng_free(OdGaussianRng * grng)
{
    assert( grng != NULL );

    if ( grng->rng != NULL )
    {
        prng_free(grng->rng);
    }

    FREE(grng);
}

void odgaussianrng_reset(OdGaussianRng * grng)
{
    assert( grng != NULL && grng->rng != NULL );

    prng_reset(grng->rng);

    grng->useLastValue = 0;    
    grng->firstValue = 0.0;
    grng->secondValue = 0.0;
}

double odgaussianrng_get_next(OdGaussianRng * grng)
{
    assert( grng != NULL && grng->rng != NULL );

    double x1, x2, w;

    if ( grng->useLastValue != 0 )
    {
	    grng->firstValue = grng->secondValue;
	    grng->useLastValue = 0;
    }
    else
    {
	    do
	    {
		    x1 = 2.0 * prng_get_next(grng->rng) - 1.0;
		    x2 = 2.0 * prng_get_next(grng->rng) - 1.0;

		    w = x1 * x1 + x2 * x2;
	    }
	    while ( w >= 1.0 || w == 0.0 );

	    w = sqrt((-2.0 * log(w)) / w );

	    grng->firstValue   = x1 * w;
	    grng->secondValue  = x2 * w;
	    grng->useLastValue = 1; 
    }

    return grng->firstValue;
}

void odgaussianrng_get_array(OdGaussianRng * grng, double * array, int numberOfElements)
{
    assert( grng != NULL && grng->rng != NULL && array != NULL && numberOfElements > 0 );

    const int danglingElement = numberOfElements % 2;
    const int numberOfLoopElements = numberOfElements - danglingElement;
    int generated = 0;

    double * numbers = ALLOC_ARRAY(double, numberOfLoopElements);

    while ( generated < numberOfLoopElements )
    {
        int pairIndex = 0;
        const int n = numberOfLoopElements - generated;
        const int maxNumberOfPairs = n - 1;

        prng_get_array(grng->rng, numbers, n);

        while ( pairIndex < maxNumberOfPairs )
        {
            double x1, x2, w;
            int invalid;

            do
            {
                x1 = 2.0 * numbers[pairIndex++] - 1.0;
                x2 = 2.0 * numbers[pairIndex  ] - 1.0;
                w = x1 * x1 + x2 * x2;
                invalid = ( w >= 1.0 || w == 0.0 );
            }
            while ( invalid && ( pairIndex < maxNumberOfPairs ));

            if ( invalid == 0 )
            {
                w = sqrt((-2.0 * log(w)) / w );

                array[generated++] = x1 * w;
                array[generated++] = x2 * w;
                pairIndex++;
            }
        }
    }

    if ( danglingElement == 1 )
    {
        array[generated] = odgaussianrng_get_next(grng);
    }

    FREE(numbers);
}

//return mean + first_value * variance;

