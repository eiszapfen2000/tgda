#ifndef ODAMPLITUDE_H_
#define ODAMPLITUDE_H_

#include "fftw3.h"
#include "Core/Math/NpMath.h"

float amplitudef_phillips_cartesian(
    const FVector2 windDirectionNormalised,
    const FVector2 k, const float A,
    const float L, const float l
    );

float amplitudef_phillips_cartesian_omnidirectional(
      const float k, const float A,
      const float L, const float l
      );

float amplitudef_phillips_polar(
    const FVector2 windDirectionNormalised,
    const float k, const float phi, const float A,
    const float L, const float l
    );


#endif

