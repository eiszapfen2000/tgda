#ifndef _NP_COLOR_WHITEPOINT_H_
#define _NP_COLOR_WHITEPOINT_H_

#include "Core/Basics/NpTypes.h"
#include "Core/Math/Vector.h"

void npcolor_whitepoint_initialise(void);

extern Vector3 * NP_WHITEPOINT_CIE_A;
extern Vector3 * NP_WHITEPOINT_CIE_C;
extern Vector3 * NP_WHITEPOINT_CIE_D50;
extern Vector3 * NP_WHITEPOINT_CIE_D55;
extern Vector3 * NP_WHITEPOINT_CIE_D65;

#endif
