#ifndef ODGAUSSIANRNG_H_
#define ODGAUSSIANRNG_H_

#include "prng.h"

void odgaussianrng_initialise();
void odgaussianrng_reset();
void odgaussianrng_shutdown();

double gaussian_fprandomnumber();
double gaussian_ss_fprandomnumber(const double mean, const double variance);

#endif

