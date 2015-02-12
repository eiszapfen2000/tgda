#define _GNU_SOURCE
#include <assert.h>
#include <math.h>
#include "ODConstants.h"
#include "ODEnergy.h"

#define PIERSON_MOSKOWITZ_alpha  0.0081
#define PIERSON_MOSKOWITZ_alphaf 0.0081f

float peak_energy_wave_frequency_pm(float U10)
{
    const float omega_p = (0.855f * EARTH_ACCELERATIONf / U10);

    return omega_p;
}

float peak_energy_wave_frequency_jonswap(float U10, float fetch)
{
    const float g = EARTH_ACCELERATIONf;
    const float X = (g * fetch) / (U10 * U10);
    const float Omega_c = 22.0f * powf(X, -0.33f);
    const float omega_p = (Omega_c * g / U10);

    return omega_p;
}

float peak_energy_wave_frequency_donelan(float U10, float fetch)
{
    const float g = EARTH_ACCELERATIONf;
    const float X = (g * fetch) / (U10 * U10);
    const float Omega_c = 11.6f * powf(X, -0.23f);
    const float omega_p = (Omega_c * g / U10);

    return omega_p;
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
    assert(omega != 0.0f);

    const float g = EARTH_ACCELERATIONf;
    const float X = (g * fetch) / (U10 * U10);
    const float Omega_c = 22.0f * powf(X, -0.33f);
    const float omega_p = (Omega_c * g / U10);
    const float alpha = 0.076f * powf(X, -0.22f);

    const float sigma = (omega > omega_p) ? 0.09f : 0.07f;
    const float omegaDiff = omega - omega_p;
    const float r_exponent = (omegaDiff*omegaDiff) / (2.0f * sigma * sigma * omega_p * omega_p);
    const float r = expf(-r_exponent);
    const float gamma_r = powf(3.3f, r);
    const float exponent = (-5.0f/4.0f) * powf(omega_p / omega, 4.0f);
    const float Theta = ((alpha*g*g) / powf(omega, 5.0f)) * expf(exponent) * gamma_r;

    return Theta;    
}

float energy_donelan_wave_frequency(float omega, float U10, float fetch)
{
    assert(omega != 0.0f);

    const float g = EARTH_ACCELERATIONf;
    const float X = (g * fetch) / (U10 * U10);
    const float Omega_c = 11.6f * powf(X, -0.23f);
    const float omega_p = (Omega_c * g / U10);
    const float alpha = 0.006f * powf(Omega_c, 0.55f);

    const float sigma = 0.08f * (1.0f + (4.0f / (Omega_c * Omega_c * Omega_c)));
    const float gamma_base = (Omega_c < 1.0f) ? 1.7f : (1.7f + 6.0f * log10f(Omega_c));
    const float omegaDiff = omega - omega_p;
    const float r_exponent = (omegaDiff*omegaDiff) / (2.0f * sigma * sigma * omega_p * omega_p);
    const float r = expf(-r_exponent);
    const float gamma_r = powf(gamma_base, r);
    const float exponent = -powf(omega_p / omega, 4.0f);
    const float Theta = ((alpha*g*g) / (powf(omega, 4.0f) * omega_p)) * expf(exponent) * gamma_r;

    return Theta;
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

float directional_spreading_donelan(float omega_p, float omega, float theta_p, float theta)
{
    const float ratio = omega / omega_p;
    const float beta
        = (ratio > 0.56f && ratio < 0.95f) ? (2.61f * powf(ratio, 1.3f))
                                           : (ratio > 0.95f && ratio < 1.6f) ? (2.28f * powf(ratio, -1.3f))
                                                                             : 1.24f;

#define sechf(x) (1.0f / coshf(x))

    const float s = sechf(beta * (theta - theta_p));
    const float result = 0.5f * beta * s * s;

#undef sechf

    return result;
}

