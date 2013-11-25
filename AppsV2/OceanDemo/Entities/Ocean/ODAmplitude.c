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


