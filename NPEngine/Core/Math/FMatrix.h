#ifndef _NP_MATH_FMATRIX_H_
#define _NP_MATH_FMATRIX_H_

#include "Core/Basics/NpTypes.h"
#include "Core/Basics/NpFreeList.h"
#include "FVector.h"

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

#define FM_ELEMENTS(_m)            (_m).elements
#define FM_ELEMENT(_m, _col, _row) (_m).elements[(_col)][(_row)]
#define FM_EL    FM_ELEMENT

FMatrix2 * fm2_alloc();
FMatrix2 * fm2_alloc_init();
FMatrix2 * fm2_free(FMatrix2 * v);
void fm2_set_identity(FMatrix2 * m);
void fm2_m_transpose_m(const FMatrix2 * const m, FMatrix2 * transpose);
void fm2_mm_add_m(const FMatrix2 * const m1, const FMatrix2 * const m2, FMatrix2 * result);
void fm2_mm_subtract_m(const FMatrix2 * const m1, const FMatrix2 * const m2, FMatrix2 * result);
void fm2_mm_multiply_m(const FMatrix2 * const m1, const FMatrix2 * const m2, FMatrix2 * result);
void fm2_vm_multiply_v(const FVector2 * const v, const FMatrix2 * const m, FVector2 * result);
void fm2_mv_multiply_v(const FMatrix2 * const m, const FVector2 * const v, FVector2 * result);
const char * fm2_m_to_string(FMatrix2 * m);

FMatrix3 * fm3_alloc();
FMatrix3 * fm3_alloc_init();
FMatrix3 * fm3_free(FMatrix3 * v);
void fm3_set_identity(FMatrix3 * m);
void fm3_m_transpose_m(const FMatrix3 * const m, FMatrix3 * transpose);
void fm3_mm_add_m(const FMatrix3 * const m1, const FMatrix3 * const m2, FMatrix3 * result);
void fm3_mm_subtract_m(const FMatrix3 * const m1, const FMatrix3 * const m2, FMatrix3 * result);
void fm3_mm_multiply_m(const FMatrix3 * const m1, const FMatrix3 * const m2, FMatrix3 * result);
void fm3_vm_multiply_v(const FVector3 * const v, const FMatrix3 * const m, FVector3 * result);
void fm3_mv_multiply_v(const FMatrix3 * const m, const FVector3 * const v, FVector3 * result);
const char * fm3_m_to_string(FMatrix3 * m);

FMatrix4 * fm4_alloc();
FMatrix4 * fm4_alloc_init();
FMatrix4 * fm4_free(FMatrix4 * v);
void fm4_m_set_identity(FMatrix4 * m);
void fm4_m_transpose_m(const FMatrix4 * const m, FMatrix4 * transpose);
void fm4_mm_add_m(const FMatrix4 * const m1, const FMatrix4 * const m2, FMatrix4 * result);
void fm4_mm_subtract_m(const FMatrix4 * const m1, const FMatrix4 * const m2, FMatrix4 * result);
void fm4_mm_multiply_m(const FMatrix4 * const m1, const FMatrix4 * const m2, FMatrix4 * result);
void fm4_vm_multiply_v(const FVector4 * const v, const FMatrix4 * const m, FVector4 * result);
void fm4_mv_multiply_v(const FMatrix4 * const m, const FVector4 * const v, FVector4 * result);
void fm4_mv_translation_matrix(FMatrix4 * m, FVector3 * v);
void fm4_msss_projection_matrix(FMatrix4 * m, Float aspectratio, Float fovdegrees, Float nearplane, Float farplane);
//void fm4_m_view_matrix(FMatrix4 * m, FVector3 * rightvector, FVector3 * upvector, FVector3 * rightvector)
const char * fm4_m_to_string(FMatrix4 * m);

#endif
