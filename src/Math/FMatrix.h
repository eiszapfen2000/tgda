#ifndef _NP_MATH_FMATRIX_H_
#define _NP_MATH_FMATRIX_H_

#include "Basics/Types.h"

#pragma pack(push)
#pragma pack(16)

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

void fm2_m_set_identity(FMatrix2 * m);
void fm3_m_set_identity(FMatrix3 * m);
void fm4_m_set_identity(FMatrix4 * m);

void fm2_m_transpose_m(const FMatrix2 * m, FMatrix2 * transpose);
void fm3_m_transpose_m(const FMatrix3 * m, FMatrix3 * transpose);
void fm4_m_transpose_m(const FMatrix4 * m, FMatrix4 * transpose);

void fm2_mm_multiply_m(const FMatrix2 * m1, const FMatrix2 * m2, FMatrix2 * result);
void fm3_mm_multiply_m(const FMatrix3 * m1, const FMatrix3 * m2, FMatrix3 * result);
void fm4_mm_multiply_m(const FMatrix4 * m1, const FMatrix4 * m2, FMatrix4 * result);

void fm2_mm_add_m(const FMatrix2 * m1, const FMatrix2 * m2, FMatrix2 * result);
void fm3_mm_add_m(const FMatrix3 * m1, const FMatrix3 * m2, FMatrix3 * result);
void fm4_mm_add_m(const FMatrix4 * m1, const FMatrix4 * m2, FMatrix4 * result);

void fm2_mm_subtract_m(const FMatrix2 * m1, const FMatrix2 * m2, FMatrix2 * result);
void fm3_mm_subtract_m(const FMatrix3 * m1, const FMatrix3 * m2, FMatrix3 * result);
void fm4_mm_subtract_m(const FMatrix4 * m1, const FMatrix4 * m2, FMatrix4 * result);

//#pragma pack(pop)

#endif
