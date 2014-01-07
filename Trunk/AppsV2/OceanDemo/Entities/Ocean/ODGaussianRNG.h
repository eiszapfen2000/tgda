#ifndef ODGAUSSIANRNG_H_
#define ODGAUSSIANRNG_H_

#include "prng.h"
#include "Core/Basics/NpTypes.h"

typedef enum OdGaussianRngType
{
    // enum limits
    OdGaussianRngTypeMin = 0,
    OdGaussianRngTypeMax = 4,
    // actual values
    OdGaussianRngTT800   = 0,
    OdGaussianRngCTG     = 1,
    OdGaussianRngMRG     = 2,
    OdGaussianRngCMRG    = 3,
    OdGaussianRngMT19937 = 4
}
OdGaussianRngType;

typedef struct OdGaussianRng
{
    struct prng * rng;
    int32_t useLastValue;
    double firstValue;
    double secondValue;
}
OdGaussianRng;

OdGaussianRng * odgaussianrng_alloc(void);
OdGaussianRng * odgaussianrng_alloc_init(void);
OdGaussianRng * odgaussianrng_alloc_init_with_type(OdGaussianRngType type);
void odgaussianrng_free(OdGaussianRng * grng);

void odgaussianrng_reset(OdGaussianRng * grng);
double odgaussianrng_get_next(OdGaussianRng * grng);
void odgaussianrng_get_array(OdGaussianRng * grng, double * array, int numberOfElements);

#endif

