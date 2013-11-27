#include "ODConstants.h"
#include "ODAmplitude.h"

float amplitudef_phillips_cartesian(
    const FVector2 windDirectionNormalised,
    const FVector2 k, const float A,
    const float L, const float l)
{
    const float kSquareLength = k.x * k.x + k.y * k.y;

    if ( kSquareLength == 0.0f )
    {
        return 0.0f;
    }

    const float kLength = sqrtf(kSquareLength);
    const FVector2 kNormalised = { .x = k.x / kLength, .y = k.y / kLength };

    float amplitude = A;
/*
    Use exp because glibc on Ubuntu 10.04 does not contain a optimised
    version of expf yet, expf is way slower than exp
*/
    amplitude = amplitude * (float)exp(( -1.0 / (kSquareLength * L * L)) - (kSquareLength * l * l));
    amplitude = amplitude * ( 1.0f / (kSquareLength * kSquareLength) );

    const float kdotw
        = kNormalised.x * windDirectionNormalised.x + kNormalised.y * windDirectionNormalised.y;

    amplitude = amplitude * kdotw * kdotw * kdotw * kdotw;

    return amplitude;
}

float amplitudef_phillips_cartesian_omnidirectional(
      const float k, const float A,
      const float L, const float l)
{
    if ( k == 0.0f )
    {
        return 0.0f;
    }

    float amplitude = A;
    amplitude = amplitude * (float)exp(( -1.0 / (k * k * L * L)) - (k * k * l * l));
    amplitude = amplitude * ( 1.0f / (k * k * k * k) );

    // This is dependent on the dot(k, wind) term in the directional version
    // 0.75 * PI represents the integral over dot(k, wind) ^ 4
    amplitude = amplitude * ( 0.75f * MATH_PIf );
    amplitude = amplitude * k;

    return amplitude;
}

float amplitudef_phillips_polar(
    const FVector2 windDirectionNormalised,
    const float k, const float phi, const float A,
    const float L, const float l)
{
    // rotate (1,0) by phi

    const float x = cosf(phi);
    const float y = sinf(phi);
    const FVector2 kv = {.x = x * k, .y = y * k};

    return
        amplitudef_phillips_cartesian(
            windDirectionNormalised,
            kv, A, L, l);
}

float amplitudef_unified_cartesian(
    const FVector2 k, const float U10,
    const float Omega
    )
{
    const float g = 9.81f;
    const float a_0 = logf(2.0f) / 4.0f;    //eq 59
    const float a_p = 4;                    //eq 59
    const float c_m = 0.23;                 //eq 59
    const float k_m = 370.0;                //eq 24
    const float kappa = 0.41f;              //von Karman constant

    const float kSquareLength = k.x * k.x + k.y * k.y;

    if ( kSquareLength == 0.0f )
    {
        return 0.0f;
    }

    const float klength = sqrtf(kSquareLength);

    //eq 24, angular frequency
    const float omega = sqrtf(g * klength * (1.0f + (klength / k_m) * (klength / k_m)));

    // phase velocity, http://en.wikipedia.org/wiki/Phase_velocity
    const float c = omega / klength;

    // spectral peak
    // right after eq 3
    const float k_p = g * (Omega / U10) * (Omega / U10);
    const float omega_p = sqrtf(g * k_p * (1.0f + (k_p / k_m) * (k_p / k_m)));
    const float c_p = omega_p / k_p;

    // friction velocity
    // eq 66
    const float z_0 = 3.7e-5f * ((U10 * U10) / g) * powf(U10 / c_p, 0.9f);
    // eq 61, solve for u* with z=10.0
    const float u_star = U10 * kappa / logf(10.0f / z_0);

    // eq 2
    const float L_pm = (float)exp((-5.0 / 4.0) * ((k_p / klength) * (k_p / klength)));

    // after eq 3
    const float gamma = Omega < 1.0f ? 1.7f : 1.7f + 6.0f * logf(Omega);

    // after eq 3
    const float sigma = 0.08f * (1.0f + (4.0f / (Omega*Omega*Omega)));

    // after eq 3
    const float Gamma = (float)exp(((sqrt(klength / k_p) - 1.0) * (sqrt(klength / k_p) - 1.0)) / (-2.0 * sigma * sigma));

    // eq 3
    const float J_p = powf(gamma, Gamma);

    // eq 32
    const float F_p = L_pm * J_p * (float)exp((sqrt(klength / k_p) - 1.0) * (-Omega / sqrt(10.0)));

    // eq 34
    const float alpha_p = 0.006f * sqrtf(Omega);

    // eq 31
    const float B_l = (0.5f * alpha_p) * (c_p / c) * F_p;

    // eq 44
    const float alpha_m = 0.01 * (u_star < c_m ? (1.0f + logf(u_star / c_m)) : (1.0f + 3.0f * logf(u_star / c_m)));

    // eq 41
    const float F_m = (float)exp(-0.25 * ((klength / k_m) - 1.0) * ((klength / k_m) - 1.0));

    // eq 40
    const float B_h = (0.5f * alpha_m) * (c_m / c) * F_m;

    // eq 59
    const float a_m = 0.13f * (u_star / c_m);
    // eq 57
    const float delta_k = (float)tanh(a_0 + a_p * pow(c / c_p, 2.5) + a_m * pow(c_m / c, 2.5));

    // eq 67
    const float phi = atan2f(k.y, k.x);
    const float Psi = (B_l + B_h) * (1.0f + delta_k * cosf(2.0f * phi)) / (MATH_2_MUL_PI * klength * klength * klength * klength);

    return Psi;
}

float amplitudef_unified_cartesian_omnidirectional(
    const float k, const float U10,
    const float Omega
    )
{
    const float g = 9.81f;
    const float a_0 = logf(2.0f) / 4.0f;    //eq 59
    const float a_p = 4;                    //eq 59
    const float c_m = 0.23;                 //eq 59
    const float k_m = 370.0;                //eq 24
    const float kappa = 0.41f;              //von Karman constant

    if ( k == 0.0f )
    {
        return 0.0f;
    }

    //eq 24, angular frequency
    const float omega = sqrtf(g * k * (1.0f + (k / k_m) * (k / k_m)));

    // phase velocity, http://en.wikipedia.org/wiki/Phase_velocity
    const float c = omega / k;

    // spectral peak
    // right after eq 3
    const float k_p = g * (Omega / U10) * (Omega / U10);
    const float omega_p = sqrtf(g * k_p * (1.0f + (k_p / k_m) * (k_p / k_m)));
    const float c_p = omega_p / k_p;

    // friction velocity
    // eq 66
    const float z_0 = 3.7e-5f * ((U10 * U10) / g) * powf(U10 / c_p, 0.9f);

    // eq 61, solve for u* with z=10.0
    const float u_star = U10 * kappa / logf(10.0f / z_0);

    // eq 2
    const float L_pm = (float)exp((-5.0 / 4.0) * ((k_p / k) * (k_p / k)));

    // after eq 3
    const float gamma = Omega < 1.0f ? 1.7f : 1.7f + 6.0f * logf(Omega);

    // after eq 3
    const float sigma = 0.08f * (1.0f + (4.0f / (Omega*Omega*Omega)));

    // after eq 3
    const float Gamma = (float)exp(((sqrt(k / k_p) - 1.0) * (sqrt(k / k_p) - 1.0)) / (-2.0 * sigma * sigma));

    // eq 3
    const float J_p = powf(gamma, Gamma);

    // eq 32
    const float F_p = L_pm * J_p * (float)exp((sqrt(k / k_p) - 1.0) * (-Omega / sqrt(10.0)));

    // eq 34
    const float alpha_p = 0.006f * sqrtf(Omega);

    // eq 31
    const float B_l = (0.5f * alpha_p) * (c_p / c) * F_p;

    // eq 44
    const float alpha_m = 0.01 * (u_star < c_m ? (1.0f + logf(u_star / c_m)) : (1.0f + 3.0f * logf(u_star / c_m)));

    // eq 41
    const float F_m = (float)exp(-0.25 * ((k / k_m) - 1.0) * ((k / k_m) - 1.0));

    // eq 40
    const float B_h = (0.5f * alpha_m) * (c_m / c) * F_m;

    // eq 30
    return (B_l + B_h) / (k * k * k);
}

float amplitudef_unified_polar(
    const float k, const float phi,
    const float U10, const float Omega
    )
{
    // rotate (1,0) by phi

    const float x = cosf(phi);
    const float y = sinf(phi);
    const FVector2 kv = {.x = x * k, .y = y * k};

    return
        amplitudef_unified_cartesian(
            kv, U10, Omega);
}


