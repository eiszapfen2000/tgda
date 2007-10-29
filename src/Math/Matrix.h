#ifndef _NP_MATH_MATRIX_H_
#define _NP_MATH_MATRIX_H_

#include "Basics/Types.h"

#include "Vector.h"

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
#define M_E     M_ELEMENT

void m2_m_set_identity(Matrix2 * m);
void m3_m_set_identity(Matrix3 * m);
void m4_m_set_identity(Matrix4 * m);

void m2_m_transpose_m(const Matrix2 * m, Matrix2 * transpose);
void m3_m_transpose_m(const Matrix3 * m, Matrix3 * transpose);
void m4_m_transpose_m(const Matrix4 * m, Matrix4 * transpose);

void m2_mm_add_m(const Matrix2 * m1, const Matrix2 * m2, Matrix2 * result);
void m3_mm_add_m(const Matrix3 * m1, const Matrix3 * m2, Matrix3 * result);
void m4_mm_add_m(const Matrix4 * m1, const Matrix4 * m2, Matrix4 * result);

void m2_mm_subtract_m(const Matrix2 * m1, const Matrix2 * m2, Matrix2 * result);
void m3_mm_subtract_m(const Matrix3 * m1, const Matrix3 * m2, Matrix3 * result);
void m4_mm_subtract_m(const Matrix4 * m1, const Matrix4 * m2, Matrix4 * result);

void m2_mm_multiply_m(const Matrix2 * m1, const Matrix2 * m2, Matrix2 * result);
void m3_mm_multiply_m(const Matrix3 * m1, const Matrix3 * m2, Matrix3 * result);
void m4_mm_multiply_m(const Matrix4 * m1, const Matrix4 * m2, Matrix4 * result);

void m2_vm_multiply_v(Vector2 * v, Matrix2 * m, Vector2 * result);
void m3_vm_multiply_v(Vector3 * v, Matrix3 * m, Vector3 * result);
void m4_vm_multiply_v(Vector4 * v, Matrix4 * m, Vector4 * result);

void m2_mv_multiply_v(Matrix2 * m, Vector2 * v, Vector2 * result);
void m3_mv_multiply_v(Matrix3 * m, Vector3 * v, Vector3 * result);
void m4_mv_multiply_v(Matrix4 * m, Vector4 * v, Vector4 * result);

#endif
