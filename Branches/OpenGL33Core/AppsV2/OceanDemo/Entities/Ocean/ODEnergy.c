#define _GNU_SOURCE
#include <assert.h>
#include <math.h>
#include <stdio.h>
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

float peak_energy_wave_number_unified(float U10, float fetch)
{
    const float g = EARTH_ACCELERATIONf;
    const float X_0 = 2.2f * powf(10.0f, 4.0f);
    const float k_0 = g / (U10 * U10);
    const float X = k_0 * fetch;
    const float Omega_c = 0.84f * powf(tanhf(powf(X/X_0, 0.4f)), -0.75f);
    const float k_p = k_0 * (Omega_c * Omega_c);

    return k_p;
}

float energy_pm_wave_frequency(float omega, float U10)
{
    assert(omega != 0.0f);

    const float g = EARTH_ACCELERATIONf;
    const float alpha = PIERSON_MOSKOWITZ_alphaf;

    const float omega_p = (0.855f * g / U10);
    // const float exponent = (-5.0f/4.0f) * powf(omega_p / omega, 4.0f);
    // const float Theta = ((alpha*g*g) / powf(omega, 5.0f)) * expf(exponent);
    const float omega_ratio = omega_p / omega;
    const float exponent = (-5.0f/4.0f) * (omega_ratio * omega_ratio * omega_ratio * omega_ratio);
    const float Theta = ((alpha*g*g) / (omega * omega * omega * omega * omega)) * expf(exponent);

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
    //const float exponent = (-5.0f/4.0f) * powf(omega_p / omega, 4.0f);
    //const float Theta = ((alpha*g*g) / powf(omega, 5.0f)) * expf(exponent) * gamma_r;
    const float omega_ratio = omega_p / omega;
    const float exponent = (-5.0f/4.0f) * (omega_ratio * omega_ratio * omega_ratio * omega_ratio);
    const float Theta = ((alpha*g*g) / (omega * omega * omega * omega * omega)) * expf(exponent) * gamma_r;
    
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

float energy_unified_wave_number(float k, float U10, float fetch)
{
    assert(k != 0.0f);

    const float g = EARTH_ACCELERATIONf;
    const float c_m = 0.23f;
    const float k_0 = g / (U10 * U10);
    const float k_m = 370.0f;
    const float X_0 = 2.2f * powf(10.0f, 4.0f);
    const float kappa = 0.41;

    const float X = k_0 * fetch;
    const float Omega_c = 0.84f * powf(tanhf(powf(X/X_0, 0.4f)), -0.75f);
    const float k_p = k_0 * (Omega_c * Omega_c);

    const float omega = sqrtf(g * k * (1.0f + (k/k_m) * (k/k_m)));
    const float c = omega / k;

    const float omega_p = sqrtf(g * k_p * (1.0f + (k_p/k_m) * (k_p/k_m)));
    const float c_p = omega_p / k_p;

    const float z_0 = 3.7e-5f * ((U10 * U10) / g) * powf(U10 / c_p, 0.9f);
    const float u_star = U10 * kappa / logf(10.0f / z_0);

    const float L_pm = expf((-5.0f/4.0f) * (k_p / k) * (k_p / k));
    const float gamma = (Omega_c < 1.0f) ? 1.7f : (1.7f + 6.0f * log10f(Omega_c));
    const float sigma = 0.08f * (1.0f + (4.0f / (Omega_c * Omega_c * Omega_c)));

    const float tmp = sqrtf(k / k_p) - 1.0f;
    const float Gamma = expf((tmp * tmp) / (-2.0f * sigma * sigma));
    const float J_p = powf(gamma, Gamma);
    const float F_p = L_pm * J_p * expf(tmp * (-Omega_c / sqrtf(10.0f)));
    const float alpha_p = 0.006f * sqrtf(Omega_c);
    const float B_l = (0.5f * alpha_p) * (c_p / c) * F_p;

    const float alpha_m
        = (u_star < c_m) ? (0.01f * (1.0f + logf(u_star / c_m)))
                         : (0.01f * (1.0f + 3.0f * logf(u_star / c_m)));

    const float F_m = L_pm * J_p * expf(-0.25f * ((k / k_m) - 1.0f) * ((k / k_m) - 1.0f));
    const float B_h = (0.5f * alpha_m) * (c_m / c) * F_m;

    const float Theta = (1.0f / (k * k * k)) * (B_l + B_h);

    return Theta;
}

float directional_spreading_mitsuyasu_hasselmann(float omega_p, float omega, float theta_p, float theta)
{
    const float s_p = (omega >= omega_p) ? 9.77f : 6.97f;
    // const float omega_div_omega_p = (omega >= omega_p) ? powf(omega / omega_p, -2.5f) : powf(omega / omega_p, 5.0f);
    const float omega_ratio = omega / omega_p;
    const float omega_div_omega_p = (omega >= omega_p) ? powf(omega_ratio, -2.5f) : (omega_ratio * omega_ratio * omega_ratio * omega_ratio * omega_ratio);
    const float s = s_p * omega_div_omega_p;

    const float numerator = tgammaf(s + 1.0f);
    const float numeratorSquare = numerator * numerator;
    const float denominator = tgammaf(2.0f * s + 1.0f);

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

float directional_spreading_unified(float U10, float k_p, float k, float theta_p, float theta)
{
    assert(k != 0.0f);

    const float g = EARTH_ACCELERATIONf;
    const float a_0 = logf(2.0f) / 4.0f;
    const float a_p = 4.0f;
    const float c_m = 0.23f;
    const float k_m = 370.0f;
    const float kappa = 0.41;

    const float omega = sqrtf(g * k * (1.0f + (k/k_m) * (k/k_m)));
    const float c = omega / k;

    const float omega_p = sqrtf(g * k_p * (1.0f + (k_p/k_m) * (k_p/k_m)));
    const float c_p = omega_p / k_p;

    const float z_0 = 3.7e-5f * ((U10 * U10) / g) * powf(U10 / c_p, 0.9f);
    const float u_star = U10 * kappa / logf(10.0f / z_0);

    const float a_m = 0.13f * (u_star / c_m);
    const float delta_k = tanhf(a_0 + a_p * powf(c /c_p, 2.5f) + a_m * powf(c_m / c, 2.5f));
    const float result = (1.0f / MATH_2_MUL_PIf) * (1.0f + delta_k * cosf(2.0f * (theta - theta_p)));

    return result;
}


