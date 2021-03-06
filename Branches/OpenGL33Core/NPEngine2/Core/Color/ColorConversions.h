#ifndef _NP_COLOR_CONVERSIONS_H_
#define _NP_COLOR_CONVERSIONS_H_

#include "Core/Basics/NpTypes.h"
#include "Core/Math/Matrix.h"

void npcolor_colorconversions_initialise(void);

extern Matrix3 * NP_LINEAR_sRGB_D65_TO_XYZ;
extern Matrix3 * NP_LINEAR_sRGB_D50_TO_XYZ;
extern Matrix3 * NP_XYZ_TO_LINEAR_sRGB_D65;
extern Matrix3 * NP_XYZ_TO_LINEAR_sRGB_D50;

void xyY_to_XYZ(const Vector3 * const xyY, Vector3 * XYZ);
void xyY_to_XYZ_safe(const Vector3 * const xyY, Vector3 * XYZ);

void XYZ_to_xyY(const Vector3 * const XYZ, Vector3 * xyY);
void XYZ_to_xyY_safe(const Vector3 * const XYZ, const Vector3 * const Whitepoint, Vector3 * xyY);

void Lab_to_XYZ(const Vector3 * const Lab, const Vector3 * const RefWhiteXYZ, Vector3 * XYZ);
void XYZ_to_Lab(const Vector3 * const XYZ, const Vector3 * const RefWhiteXYZ, Vector3 * Lab);

void XYZ_to_linear_RGB(const Vector3 * const XYZ, const Matrix3 * const InvM, Vector3 * RGB);
void linear_RGB_to_XYZ(const Vector3 * const RGB, const Matrix3 * const M, Vector3 * XYZ);

double gamma_companding(double LinearValue, double Gamma);
double gamma_inverse_companding(double Value, double Gamma);
double sRGB_companding(double LinearValue);
double sRGB_inverse_companding(double Value);

void linear_RGB_to_sRGB(const Vector3 * const RGB, Vector3 * sRGB);
void linear_RGB_to_sRGB_safe(const Vector3 * const RGB, Vector3 * sRGB);
void sRGB_to_linear_RGB(const Vector3 * const sRGB, Vector3 * RGB);

#endif
