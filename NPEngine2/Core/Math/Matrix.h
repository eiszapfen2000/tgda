#ifndef _NP_MATH_MATRIX_H_
#define _NP_MATH_MATRIX_H_

#include "Core/Basics/NpTypes.h"
#include "Accessors.h"
#include "Vector.h"

void npmath_matrix_initialise();

//first index = column

struct FMatrix2;
struct FMatrix3;
struct FMatrix4;

typedef struct Matrix2
{
    double elements[2][2];
}
Matrix2;

typedef struct Matrix3
{
    double elements[3][3];
}
Matrix3;

typedef struct Matrix4
{
    double elements[4][4];
}
Matrix4;

Matrix2 * m2_alloc();
Matrix2 * m2_alloc_init();
void m2_free(Matrix2 * m);
void m2_m_set_identity(Matrix2 * m);
void m2_m_transpose_m(const Matrix2 * const m, Matrix2 * transpose);
void m2_mm_add_m(const Matrix2 * const m1, const Matrix2 * const m2, Matrix2 * result);
void m2_mm_subtract_m(const Matrix2 * const m1, const Matrix2 * const m2, Matrix2 * result);
void m2_mm_multiply_m(const Matrix2 * const m1, const Matrix2 * const m2, Matrix2 * result);
void m2_vm_multiply_v(const Vector2 * const v, const Matrix2 * const m, Vector2 * result);
void m2_mv_multiply_v(const Matrix2 * const m, const Vector2 * const v, Vector2 * result);
void m2_m_inverse_m(const Matrix2 * const m1, Matrix2 * m2);
double m2_determinant(const Matrix2 * const m);
Matrix2 m2_m_transposed(const Matrix2 const * m);
Matrix2 m2_mm_add(const Matrix2 * const m1, const Matrix2 * const m2);
Matrix2 m2_mm_subtract(const Matrix2 * const m1, const Matrix2 * const m2);
Matrix2 m2_mm_multiply(const Matrix2 * const m1, const Matrix2 * const m2);
Vector2 m2_vm_multiply(const Vector2 * const v, const Matrix2 * const m);
Vector2 m2_mv_multiply(const Matrix2 * const m, const Vector2 * const v);
Matrix2 m2_m_inverse(const Matrix2 * const m);
const char * m2_m_to_string(Matrix2 * m);

Matrix3 * m3_alloc();
Matrix3 * m3_alloc_init();
void m3_free(Matrix3 * m);
void m3_m_set_identity(Matrix3 * m);
void m3_m_transpose_m(const Matrix3 * const m, Matrix3 * transpose);
void m3_mm_add_m(const Matrix3 * const m1, const Matrix3 * const m2, Matrix3 * result);
void m3_mm_subtract_m(const Matrix3 * const m1, const Matrix3 * const m2, Matrix3 * result);
void m3_mm_multiply_m(const Matrix3 * const m1, const Matrix3 * const m2, Matrix3 * result);
void m3_vm_multiply_v(const Vector3 * const v, const Matrix3 * const m, Vector3 * result);
void m3_mv_multiply_v(const Matrix3 * const m, const Vector3 * const v, Vector3 * result);
void m3_m_inverse_m(const Matrix3 * const m1, Matrix3 * m2);
void m3_m_get_right_vector_v(const Matrix3 * const m, Vector3 * right);
void m3_m_get_up_vector_v(const Matrix3 * const m, Vector3 * up);
void m3_m_get_forward_vector_v(const Matrix3 * const m, Vector3 * forward);
void m3_s_rotatex_m(double degree, Matrix3 * result);
void m3_s_rotatey_m(double degree, Matrix3 * result);
void m3_s_rotatez_m(double degree, Matrix3 * result);
void m3_s_scalex_m(double scale, Matrix3 * result);
void m3_s_scaley_m(double scale, Matrix3 * result);
void m3_s_scalez_m(double scale, Matrix3 * result);
void m3_s_scale_m(double scale, Matrix3 * result);
double m3_m_determinant(const Matrix3 * const m);
Matrix3 m3_m_transposed(const Matrix3 const * m);
Matrix3 m3_mm_add(const Matrix3 * const m1, const Matrix3 * const m2);
Matrix3 m3_mm_subtract(const Matrix3 * const m1, const Matrix3 * const m2);
Matrix3 m3_mm_multiply(const Matrix3 * const m1, const Matrix3 * const m2);
Vector3 m3_vm_multiply(const Vector3 * const v, const Matrix3 * const m);
Vector3 m3_mv_multiply(const Matrix3 * const m, const Vector3 * const v);
Matrix3 m3_m_inverse(const Matrix3 * const m);
Vector3 m3_m_get_right_vector(const Matrix3 * const m);
Vector3 m3_m_get_up_vector(const Matrix3 * const m);
Vector3 m3_m_get_forward_vector(const Matrix3 * const m);
Matrix3 m3_s_rotatex(double degree);
Matrix3 m3_s_rotatey(double degree);
Matrix3 m3_s_rotatez(double degree);
Matrix3 m3_s_scalex(double scale);
Matrix3 m3_s_scaley(double scale);
Matrix3 m3_s_scalez(double scale);
Matrix3 m3_s_scale(double scale);
const char * m3_m_to_string(Matrix3 * m);

Matrix4 * m4_alloc();
Matrix4 * m4_alloc_init();
void m4_free(Matrix4 * m);
void m4_m_set_identity(Matrix4 * m);
void m4_m_transpose_m(const Matrix4 * const m, Matrix4 * transpose);
void m4_mm_add_m(const Matrix4 * const m1, const Matrix4 * const m2, Matrix4 * result);
void m4_mm_subtract_m(const Matrix4 * const m1, const Matrix4 * const m2, Matrix4 * result);
void m4_mm_multiply_m(const Matrix4 * const m1, const Matrix4 * const m2, Matrix4 * result);
void m4_vm_multiply_v(const Vector4 * const v, const Matrix4 * const m, Vector4 * result);
void m4_mv_multiply_v(const Matrix4 * const m, const Vector4 * const v, Vector4 * result);
void m4_mv_translation_matrix(Matrix4 * m, const Vector3 * const v);
void m4_mv_scale_matrix(Matrix4 * m, const Vector3 * const v);
void m4_ms_scale_matrix_x(Matrix4 * m, double x);
void m4_ms_scale_matrix_y(Matrix4 * m, double y);
void m4_ms_scale_matrix_z(Matrix4 * m, double z);
void m4_msss_scale_matrix_xyz(Matrix4 * m, double x, double y, double z);
void m4_vvv_look_at_matrix_m(Vector3 * eyePosition, Vector3 * lookAtPosition, Vector3 * upVector, Matrix4 * result);
void m4_vvvv_look_at_matrix_m(Vector3 * rightVector, Vector3 * upVector, Vector3 * forwardVector, Vector3 * position, Matrix4 * result);
void m4_mssss_projection_matrix(Matrix4 * m, double aspectratio, double fovdegrees, double nearplane, double farplane);
void m4_ms_simple_orthographic_projection_matrix(Matrix4 * m, double aspectratio);
void m4_mssssss_orthographic_projection_matrix(Matrix4 * m, double left, double right, double bottom, double top, double near, double far);
void m4_mssss_orthographic_2d_projection_matrix(Matrix4 * m, double left, double right, double bottom, double top);
void m4_mss_sub_matrix_m(const Matrix4 * const m, const int row, const int column, Matrix3 * result);
void m4_m_inverse_m(const Matrix4 * const m, Matrix4 * result);
void m4_m_get_right_vector_v(const Matrix4 * const m, Vector3 * right);
void m4_m_get_up_vector_v(const Matrix4 * const m, Vector3 * up);
void m4_m_get_forward_vector_v(const Matrix4 * const m, Vector3 * forward);
void m4_s_rotatex_m(double degree, Matrix4 * result);
void m4_s_rotatey_m(double degree, Matrix4 * result);
void m4_s_rotatez_m(double degree, Matrix4 * result);
double m4_m_determinant(const Matrix4 * const m);
Matrix4 m4_m_transposed(const Matrix4 * const m);
Matrix4 m4_mm_add(const Matrix4 * const m1, const Matrix4 * const m2);
Matrix4 m4_mm_subtract(const Matrix4 * const m1, const Matrix4 * const m2);
Matrix4 m4_mm_multiply(const Matrix4 * const m1, const Matrix4 * const m2);
Vector4 m4_vm_multiply(const Vector4 * const v, const Matrix4 * const m);
Vector4 m4_mv_multiply(const Matrix4 * const m, const Vector4 * const v);
Matrix4 m4_v_translation_matrix(const Vector3 * const v);
const char * m4_m_to_string(Matrix4 * m);

#endif
