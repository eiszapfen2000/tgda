#ifndef _NP_MATH_MATRIX_H_
#define _NP_MATH_MATRIX_H_

#include "Basics/Types.h"

typedef struct
{
    Real elements[3][3];
}
Matrix3;

typedef struct
{
    Real elements[4][4];
}
Matrix4;

#endif
