#ifndef _NP_MATH_FMATRIX_H_
#define _NP_MATH_FMATRIX_H_

#include "Core/Basics/NpTypes.h"
#include "Core/Basics/NpFreeList.h"
#include "FVector.h"

extern NpFreeList * NP_FMATRIX2_FREELIST;
extern NpFreeList * NP_FMATRIX3_FREELIST;
extern NpFreeList * NP_FMATRIX4_FREELIST;

void npmath_fmatrix_initialise();

typedef struct FMatrix2
{
    Float elements[2][2];
}
FMatrix2;

typedef struct FMatrix3
{
    Float elements[3][3];
}
FMatrix3;

typedef struct FMatrix4
{
    Float elements[4][4];
}
FMatrix4;

#define FM_ELEMENT(_m2, _col, _row) (_m2).elements[(_col)][(_row)]
#define FM_EL    FM_ELEMENT

void fm2_set_identity(FMatrix2 * m);
void fm2_m_transpose_m(const FMatrix2 * const m, FMatrix2 * transpose);
void fm2_mm_add_m(const FMatrix2 * const m1, const FMatrix2 * const m2, FMatrix2 * result);
void fm2_mm_subtract_m(const FMatrix2 * const m1, const FMatrix2 * const m2, FMatrix2 * result);
void fm2_mm_multiply_m(const FMatrix2 * const m1, const FMatrix2 * const m2, FMatrix2 * result);
void fm2_vm_multiply_v(const FVector2 * const v, const FMatrix2 * const m, FVector2 * result);
void fm2_mv_multiply_v(const FMatrix2 * const m, const FVector2 * const v, FVector2 * result);
FMatrix2 * fm2_alloc();
FMatrix2 * fm2_alloc_init();

void fm3_set_identity(FMatrix3 * m);
void fm3_m_transpose_m(const FMatrix3 * const m, FMatrix3 * transpose);
void fm3_mm_add_m(const FMatrix3 * const m1, const FMatrix3 * const m2, FMatrix3 * result);
void fm3_mm_subtract_m(const FMatrix3 * const m1, const FMatrix3 * const m2, FMatrix3 * result);
void fm3_mm_multiply_m(const FMatrix3 * const m1, const FMatrix3 * const m2, FMatrix3 * result);
void fm3_vm_multiply_v(const FVector3 * const v, const FMatrix3 * const m, FVector3 * result);
void fm3_mv_multiply_v(const FMatrix3 * const m, const FVector3 * const v, FVector3 * result);
FMatrix3 * fm3_alloc();
FMatrix3 * fm3_alloc_init();

void fm4_set_identity(FMatrix4 * m);
void fm4_m_transpose_m(const FMatrix4 * const m, FMatrix4 * transpose);
void fm4_mm_add_m(const FMatrix4 * const m1, const FMatrix4 * const m2, FMatrix4 * result);
void fm4_mm_subtract_m(const FMatrix4 * const m1, const FMatrix4 * const m2, FMatrix4 * result);
void fm4_mm_multiply_m(const FMatrix4 * const m1, const FMatrix4 * const m2, FMatrix4 * result);
void fm4_vm_multiply_v(const FVector4 * const v, const FMatrix4 * const m, FVector4 * result);
void fm4_mv_multiply_v(const FMatrix4 * const m, const FVector4 * const v, FVector4 * result);
FMatrix4 * fm4_alloc();
FMatrix4 * fm4_alloc_init();

#endif
