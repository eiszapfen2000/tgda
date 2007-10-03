#ifndef _NP_MATH_MATRIX_H_
#define _NP_MATH_MATRIX_H_

#include "Basics/Types.h"

//first index = column

typedef struct
{
    Double elements[2][2];
}
Matrix2;

typedef struct
{
    Double elements[3][3];
}
Matrix3;

typedef struct
{
    Double elements[4][4];
}
Matrix4;

#define M_ELEMENT(_m2, _col, _row) (_m2).elements[(_col)][(_row)]

void m2_mm_multiply_m(Matrix2 * m1, Matrix2 * m2, Matrix2 * result);
void m3_mm_multiply_m(Matrix3 * m1, Matrix3 * m2, Matrix3 * result);
void m4_mm_multiply_m(Matrix4 * m1, Matrix4 * m2, Matrix4 * result);

#endif
