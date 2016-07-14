#ifndef _NP_COLOR_CONVERSIONS_H_
#define _NP_COLOR_CONVERSIONS_H_

#include "Core/Basics/NpTypes.h"
#include "Core/Math/Matrix.h"

void npcolor_colorconversions_initialise(void);

extern Matrix3 * NP_LINEAR_sRGB_D65_TO_XYZ;
extern Matrix3 * NP_LINEAR_sRGB_D50_TO_XYZ;

extern Matrix3 * NP_XYZ_TO_LINEAR_sRGB_65;
extern Matrix3 * NP_XYZ_TO_LINEAR_sRGB_50;

#endif
