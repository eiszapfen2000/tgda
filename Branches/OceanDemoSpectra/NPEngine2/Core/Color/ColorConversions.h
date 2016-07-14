#ifndef _NP_COLOR_CONVERSIONS_H_
#define _NP_COLOR_CONVERSIONS_H_

#include "Core/Basics/NpTypes.h"
#include "Core/Math/Matrix.h"

void npcolor_colorconversions_initialise(void);

extern Matrix3 * NP_LINEAR_sRGB_D65_TO_XYZ;
extern Matrix3 * NP_LINEAR_sRGB_D50_TO_XYZ;

extern Matrix3 * NP_XYZ_TO_LINEAR_sRGB_65;
extern Matrix3 * NP_XYZ_TO_LINEAR_sRGB_50;

void xyY_to_XYZ(const Vector3 * const xyY, Vector3 * XYZ);
void XYZ_to_xyY(const Vector3 * const XYZ, Vector3 * xyY);
void Lab_to_XYZ(const Vector3 * Lab, const Vector3 * RefWhiteXYZ, Vector3 * XYZ);
void XYZ_to_Lab(const Vector3 * XYZ, const Vector3 * RefWhiteXYZ, Vector3 * Lab);

#endif
