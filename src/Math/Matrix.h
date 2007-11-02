#ifndef _NP_MATH_MATRIX_H_
#define _NP_MATH_MATRIX_H_

#include "Basics/Types.h"
#include "Basics/NpFreeList.h"
#include "Vector.h"

extern NpFreeList * NP_MATRIX2_FREELIST;
extern NpFreeList * NP_MATRIX3_FREELIST;
extern NpFreeList * NP_MATRIX4_FREELIST;

void npmath_matrix_initialise();

//first index = column

typedef struct Matrix2
{
    Double elements[2][2];
}
Matrix2;

typedef struct Matrix3
{
    Double elements[3][3];
}
Matrix3;

typedef struct Matrix4
{
    Double elements[4][4];
}
Matrix4;

#define M_ELEMENT(_m, _col, _row) (_m).elements[(_col)][(_row)]
#define M_EL     M_ELEMENT

Matrix2 * m2_alloc();
Matrix2 * m2_alloc_init();
Matrix2 * m2_free(Matrix2 * m);
void m2_set_identity(Matrix2 * m);
void m2_m_transpose_m(const Matrix2 * const m, Matrix2 * transpose);
void m2_mm_add_m(const Matrix2 * const m1, const Matrix2 * const m2, Matrix2 * result);
void m2_mm_subtract_m(const Matrix2 * const m1, const Matrix2 * const m2, Matrix2 * result);
void m2_mm_multiply_m(const Matrix2 * const m1, const Matrix2 * const m2, Matrix2 * result);
void m2_vm_multiply_v(const Vector2 * const v, const Matrix2 * const m, Vector2 * result);
void m2_mv_multiply_v(const Matrix2 * const m, const Vector2 * const v, Vector2 * result);

Matrix3 * m3_alloc();
Matrix3 * m3_alloc_init();
Matrix3 * m3_free(Matrix3 * m);
void m3_set_identity(Matrix3 * m);
void m3_m_transpose_m(const Matrix3 * const m, Matrix3 * transpose);
void m3_mm_add_m(const Matrix3 * const m1, const Matrix3 * const m2, Matrix3 * result);
void m3_mm_subtract_m(const Matrix3 * const m1, const Matrix3 * const m2, Matrix3 * result);
void m3_mm_multiply_m(const Matrix3 * const m1, const Matrix3 * const m2, Matrix3 * result);
void m3_vm_multiply_v(const Vector3 * const v, const Matrix3 * const m, Vector3 * result);
void m3_mv_multiply_v(const Matrix3 * const m, const Vector3 * const v, Vector3 * result);

Matrix4 * m4_alloc();
Matrix4 * m4_alloc_init();
Matrix4 * m4_free(Matrix4 * m);
void m4_set_identity(Matrix4 * m);
void m4_m_transpose_m(const Matrix4 * const m, Matrix4 * transpose);
void m4_mm_add_m(const Matrix4 * const m1, const Matrix4 * const m2, Matrix4 * result);
void m4_mm_subtract_m(const Matrix4 * const m1, const Matrix4 * const m2, Matrix4 * result);
void m4_mm_multiply_m(const Matrix4 * const m1, const Matrix4 * const m2, Matrix4 * result);
void m4_vm_multiply_v(const Vector4 * const v, const Matrix4 * const m, Vector4 * result);
void m4_mv_multiply_v(const Matrix4 * const m, const Vector4 * const v, Vector4 * result);

#endif
