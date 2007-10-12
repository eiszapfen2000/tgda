#ifndef _NP_MATH_FMATRIX_H_
#define _NP_MATH_FMATRIX_H_

#include "Basics/Types.h"

typedef struct
{
    Float elements[2][2];
}
FMatrix2;

typedef struct
{
    Float elements[3][3];
}
FMatrix3;

typedef struct
{
    Float elements[4][4];
}
FMatrix4;

#define FM_ELEMENT(_m2, _col, _row) (_m2).elements[(_col)][(_row)]
#define FM_E    FM_ELEMENT

void fm2_mm_multiply_m(FMatrix2 * m1, FMatrix2 * m2, FMatrix2 * result);
void fm3_mm_multiply_m(FMatrix3 * m1, FMatrix3 * m2, FMatrix3 * result);
void fm4_mm_multiply_m(FMatrix4 * m1, FMatrix4 * m2, FMatrix4 * result);

#endif
