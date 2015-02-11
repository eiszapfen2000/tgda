#define _GNU_SOURCE
#include <assert.h>
#include <math.h>
#include "ODConstants.h"
#include "ODEnergy.h"

#define PIERSON_MOSKOWITZ_alpha  0.0081
#define PIERSON_MOSKOWITZ_alphaf 0.0081f

float peak_energy_wave_frequency_pm(float U10)
{
    return (0.855f * EARTH_ACCELERATIONf / U10);
}

float peak_energy_wave_frequency_jonswap(float U10)
{
    return 0.0f;
}

float energy_pm_wave_frequency(float omega, float U10)
{
    assert(omega != 0.0f);

    const float g = EARTH_ACCELERATIONf;
    const float alpha = PIERSON_MOSKOWITZ_alphaf;

    const float omega_p = (0.855f * g / U10);
    const float exponent = (-5.0f/4.0f) * powf(omega_p / omega, 4.0f);
    const float Theta = ((alpha*g*g) / powf(omega, 5.0f)) * expf(exponent);

    return Theta;
}

float energy_jonswap_wave_frequency(float omega, float U10, float fetch)
{
    return 0.0f;
}

float directional_spreading_mitsuyasu_hasselmann(float omega_p, float omega, float theta_p, float theta)
{
    const float s_p = (omega >= omega_p) ? 9.77f : 6.97f;
    const float omega_div_omega_p = (omega >= omega_p) ? powf(omega / omega_p, -2.5f) : powf(omega / omega_p, 5.0f);
    const float s = s_p * omega_div_omega_p;

    const float numerator = tgammaf(s + 1.0f);
    const float numeratorSquare = numerator * numerator;
    const float denominator = tgamma(2.0f * s + 1.0f);

    const float term_one = powf(2.0f, 2.0f * s - 1.0f) / MATH_PIf;
    const float term_two = numeratorSquare / denominator;
    const float term_three = powf(fabsf(cosf((theta - theta_p) * 0.5f)), 2.0f * s);

    return term_one * term_two * term_three;
}

