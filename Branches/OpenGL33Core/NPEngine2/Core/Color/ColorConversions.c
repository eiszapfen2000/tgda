#include <assert.h>
#include <math.h>
#include "ColorConversions.h"

Matrix3 * NP_LINEAR_sRGB_D65_TO_XYZ = NULL;
Matrix3 * NP_LINEAR_sRGB_D50_TO_XYZ = NULL;
Matrix3 * NP_XYZ_TO_LINEAR_sRGB_D65 = NULL;
Matrix3 * NP_XYZ_TO_LINEAR_sRGB_D50 = NULL;


void npcolor_colorconversions_initialise(void)
{
	NP_LINEAR_sRGB_D65_TO_XYZ = m3_alloc_init();
	NP_LINEAR_sRGB_D50_TO_XYZ = m3_alloc_init();

	NP_XYZ_TO_LINEAR_sRGB_D65 = m3_alloc_init();
	NP_XYZ_TO_LINEAR_sRGB_D50 = m3_alloc_init();

	// http://www.brucelindbloom.com/Eqn_RGB_XYZ_Matrix.html

	/*
	sRGB D65 to XYZ
	0.4124564  0.3575761  0.1804375
	0.2126729  0.7151522  0.0721750
	0.0193339  0.1191920  0.9503041
	*/

	M_EL(*NP_LINEAR_sRGB_D65_TO_XYZ, 0, 0) = 0.4124564; M_EL(*NP_LINEAR_sRGB_D65_TO_XYZ, 1, 0) = 0.3575761; M_EL(*NP_LINEAR_sRGB_D65_TO_XYZ, 2, 0) = 0.1804375;
	M_EL(*NP_LINEAR_sRGB_D65_TO_XYZ, 0, 1) = 0.2126729; M_EL(*NP_LINEAR_sRGB_D65_TO_XYZ, 1, 1) = 0.7151522; M_EL(*NP_LINEAR_sRGB_D65_TO_XYZ, 2, 1) = 0.0721750;
	M_EL(*NP_LINEAR_sRGB_D65_TO_XYZ, 0, 2) = 0.0193339; M_EL(*NP_LINEAR_sRGB_D65_TO_XYZ, 1, 2) = 0.1191920; M_EL(*NP_LINEAR_sRGB_D65_TO_XYZ, 2, 2) = 0.9503041;

	/*
	sRGB D50 to XYZ
	0.4360747  0.3850649  0.1430804
	0.2225045  0.7168786  0.0606169
	0.0139322  0.0971045  0.7141733
	*/

	M_EL(*NP_LINEAR_sRGB_D50_TO_XYZ, 0, 0) = 0.4360747; M_EL(*NP_LINEAR_sRGB_D50_TO_XYZ, 1, 0) = 0.3850649; M_EL(*NP_LINEAR_sRGB_D50_TO_XYZ, 2, 0) = 0.1430804;
	M_EL(*NP_LINEAR_sRGB_D50_TO_XYZ, 0, 1) = 0.2225045; M_EL(*NP_LINEAR_sRGB_D50_TO_XYZ, 1, 1) = 0.7168786; M_EL(*NP_LINEAR_sRGB_D50_TO_XYZ, 2, 1) = 0.0606169;
	M_EL(*NP_LINEAR_sRGB_D50_TO_XYZ, 0, 2) = 0.0139322; M_EL(*NP_LINEAR_sRGB_D50_TO_XYZ, 1, 2) = 0.0971045; M_EL(*NP_LINEAR_sRGB_D50_TO_XYZ, 2, 2) = 0.7141733;	 

	/*
	XYZ to sRGB D65
	3.2404542 -1.5371385 -0.4985314
	-0.9692660  1.8760108  0.0415560
	0.0556434 -0.2040259  1.0572252
	*/

	M_EL(*NP_XYZ_TO_LINEAR_sRGB_D65, 0, 0) =  3.2404542; M_EL(*NP_XYZ_TO_LINEAR_sRGB_D65, 1, 0) = -1.5371385; M_EL(*NP_XYZ_TO_LINEAR_sRGB_D65, 2, 0) = -0.4985314;
	M_EL(*NP_XYZ_TO_LINEAR_sRGB_D65, 0, 1) = -0.9692660; M_EL(*NP_XYZ_TO_LINEAR_sRGB_D65, 1, 1) =  1.8760108; M_EL(*NP_XYZ_TO_LINEAR_sRGB_D65, 2, 1) =  0.0415560;
	M_EL(*NP_XYZ_TO_LINEAR_sRGB_D65, 0, 2) =  0.0556434; M_EL(*NP_XYZ_TO_LINEAR_sRGB_D65, 1, 2) = -0.2040259; M_EL(*NP_XYZ_TO_LINEAR_sRGB_D65, 2, 2) =  1.0572252;

	/*
	XYZ to sRGB D50
	 3.1338561 -1.6168667 -0.4906146
	-0.9787684  1.9161415  0.0334540
	 0.0719453 -0.2289914  1.4052427
	 */

	M_EL(*NP_XYZ_TO_LINEAR_sRGB_D50, 0, 0) =  3.1338561; M_EL(*NP_XYZ_TO_LINEAR_sRGB_D50, 1, 0) = -1.6168667; M_EL(*NP_XYZ_TO_LINEAR_sRGB_D50, 2, 0) = -0.4906146;
	M_EL(*NP_XYZ_TO_LINEAR_sRGB_D50, 0, 1) = -0.9787684; M_EL(*NP_XYZ_TO_LINEAR_sRGB_D50, 1, 1) =  1.9161415; M_EL(*NP_XYZ_TO_LINEAR_sRGB_D50, 2, 1) =  0.0334540;
	M_EL(*NP_XYZ_TO_LINEAR_sRGB_D50, 0, 2) =  0.0719453; M_EL(*NP_XYZ_TO_LINEAR_sRGB_D50, 1, 2) = -0.2289914; M_EL(*NP_XYZ_TO_LINEAR_sRGB_D50, 2, 2) =  1.4052427;
}

void xyY_to_XYZ(const Vector3 * const xyY, Vector3 * XYZ)
{
	assert(xyY->y > 0.0);

	XYZ->x = (xyY->x * xyY->z) / xyY->y;
	XYZ->y = xyY->z;
	XYZ->z = ((1.0 - (xyY->x + xyY->y)) * xyY->z) / xyY->y;
}

void xyY_to_XYZ_safe(const Vector3 * const xyY, Vector3 * XYZ)
{
	XYZ->x = XYZ->y = XYZ->z = 0.0;

	if (xyY->y > 0.0)
	{
		xyY_to_XYZ(xyY, XYZ);
	}
}

void XYZ_to_xyY(const Vector3 * const XYZ, Vector3 * xyY)
{
	double s = (XYZ->x + XYZ->y + XYZ->z);

	assert(s > 0.0);

	xyY->x = XYZ->x / s;
	xyY->y = XYZ->y / s;
	xyY->z = XYZ->y;
}

void XYZ_to_xyY_safe(const Vector3 * const XYZ, const Vector3 * const WhitepointXYZ, Vector3 * xyY)
{
	// convert whitepoint XYZ to xyY
	Vector3 whitepoint_xyY;
	XYZ_to_xyY(WhitepointXYZ, &whitepoint_xyY);

	// set result to whitepoint chroma and XYZ input luminance
	xyY->x = whitepoint_xyY.x;
	xyY->y = whitepoint_xyY.y;
	xyY->z = XYZ->y;

	double s = (XYZ->x + XYZ->y + XYZ->z);

	// only convert iff XYZ is not zero
	if (s > 0.0)
	{
		xyY->x = XYZ->x / s;
		xyY->y = XYZ->y / s;
	}	
}

void Lab_to_XYZ(const Vector3 * const Lab, const Vector3 * const RefWhiteXYZ, Vector3 * XYZ)
{
	const double epsilon = 216.0 / 24389.0;
	const double kappa = 24389.0 / 27.0;

	const double fy = (Lab->x + 16.0) / 116.0;
	const double fx = (Lab->y / 500.0) + fy;
	const double fz = fy - (Lab->z / 200.0);

	const double fx3 = pow(fx, 3.0);
	const double fy3 = pow(fy, 3.0);
	const double fz3 = pow(fz, 3.0);

	const double xr = (fx3 > epsilon) ? fx3 : ((116.0*fx - 16.0) / kappa);
	const double yr = (Lab->x > (kappa*epsilon)) ? fy3 : (Lab->x / kappa);
	const double zr = (fz3 > epsilon) ? fz3 : ((116.0*fz - 16.0) / kappa);

	XYZ->x = xr * RefWhiteXYZ->x;
	XYZ->y = yr * RefWhiteXYZ->y;
	XYZ->z = zr * RefWhiteXYZ->z;
}

void XYZ_to_Lab(const Vector3 * const XYZ, const Vector3 * const RefWhiteXYZ, Vector3 * Lab)
{
	const double epsilon = 216.0 / 24389.0;
	const double kappa = 24389.0 / 27.0;

	const double xr = XYZ->x / RefWhiteXYZ->x;
	const double yr = XYZ->y / RefWhiteXYZ->y;
	const double zr = XYZ->z / RefWhiteXYZ->z;

	const double fx = (xr > epsilon) ? pow(xr, 1.0/3.0) : ((kappa*xr + 16.0) / 116.0);
	const double fy = (yr > epsilon) ? pow(yr, 1.0/3.0) : ((kappa*yr + 16.0) / 116.0);
	const double fz = (zr > epsilon) ? pow(zr, 1.0/3.0) : ((kappa*zr + 16.0) / 116.0);

	Lab->x = 116.0 * fy - 16.0;
	Lab->y = 500.0 * (fx - fy);
	Lab->z = 200.0 * (fy - fz);
}

void XYZ_to_linear_RGB(const Vector3 * const XYZ, const Matrix3 * const InvM, Vector3 * RGB)
{
	m3_mv_multiply_v(InvM, XYZ, RGB);
}

void linear_RGB_to_XYZ(const Vector3 * const RGB, const Matrix3 * const M, Vector3 * XYZ)
{
	m3_mv_multiply_v(M, RGB, XYZ);
}

double gamma_companding(double LinearValue, double Gamma)
{
	assert(LinearValue >= 0.0 && LinearValue <= 1.0 && Gamma > 0.0);

	return pow(LinearValue, 1.0/Gamma);
}

double gamma_inverse_companding(double Value, double Gamma)
{
	assert(Value >= 0.0 && Value <= 1.0 && Value > 0.0);

	return pow(Value, Gamma);
}

double sRGB_companding(double LinearValue)
{
	assert(LinearValue >= 0.0 && LinearValue <= 1.0);

	return (LinearValue > 0.0031308) ? (1.055 * pow(LinearValue, 1.0/2.4) - 0.055) : (12.92 * LinearValue);
}

double sRGB_inverse_companding(double Value)
{
	assert(Value >= 0.0 && Value <= 1.0);

	return (Value > 0.04045) ? pow((Value + 0.055) / 1.055, 2.4) : (Value / 12.92);
}

void linear_RGB_to_sRGB(const Vector3 * const RGB, Vector3 * sRGB)
{
	sRGB->x = sRGB_companding(RGB->x);
	sRGB->y = sRGB_companding(RGB->y);
	sRGB->z = sRGB_companding(RGB->z);
}

#ifndef MIN
#define MIN(_a,_b) ((_a < _b )? _a:_b)
#endif

#ifndef MAX
#define MAX(_a,_b) ((_a > _b )? _a:_b)
#endif

void linear_RGB_to_sRGB_safe(const Vector3 * const RGB, Vector3 * sRGB)
{
	// clamp negative values
	Vector3 rgb;
	rgb.x = MAX(0.0, RGB->x);
	rgb.y = MAX(0.0, RGB->y);
	rgb.z = MAX(0.0, RGB->z);

	// scale into range [0...1]
	double maxValue = MAX(MAX(rgb.x, rgb.y), rgb.z);

	if (maxValue > 1.0)
	{
		rgb.x = MIN(1.0, rgb.x / maxValue);
		rgb.y = MIN(1.0, rgb.y / maxValue);
		rgb.z = MIN(1.0, rgb.z / maxValue);
	}

	// convert
	linear_RGB_to_sRGB(&rgb, sRGB);
}

void sRGB_to_linear_RGB(const Vector3 * const sRGB, Vector3 * RGB)
{
	RGB->x = sRGB_inverse_companding(sRGB->x);
	RGB->y = sRGB_inverse_companding(sRGB->y);
	RGB->z = sRGB_inverse_companding(sRGB->z);
}
