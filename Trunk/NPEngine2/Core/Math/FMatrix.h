#ifndef _NP_MATH_FMATRIX_H_
#define _NP_MATH_FMATRIX_H_

#include "Core/Basics/NpTypes.h"
#include "Accessors.h"
#include "FVector.h"

void npmath_fmatrix_initialise(void);

struct Matrix2;
struct Matrix3;
struct Matrix4;

//first index = column

typedef struct FMatrix2
{
    float elements[2][2];
}
FMatrix2;

typedef struct FMatrix3
{
    float elements[3][3];
}
FMatrix3;

typedef struct FMatrix4
{
    float elements[4][4];
}
FMatrix4;

FMatrix2 * fm2_alloc(void);
FMatrix2 * fm2_alloc_init(void);
void fm2_free(FMatrix2 * v);
void fm2_m_set_identity(FMatrix2 * m);
void fm2_m_init_with_m2(FMatrix2 * m1, const struct Matrix2 * const m2);
void fm2_m_transpose_m(const FMatrix2 * const m, FMatrix2 * transpose);
void fm2_mm_add_m(const FMatrix2 * const m1, const FMatrix2 * const m2, FMatrix2 * result);
void fm2_mm_subtract_m(const FMatrix2 * const m1, const FMatrix2 * const m2, FMatrix2 * result);
void fm2_mm_multiply_m(const FMatrix2 * const m1, const FMatrix2 * const m2, FMatrix2 * result);
void fm2_vm_multiply_v(const FVector2 * const v, const FMatrix2 * const m, FVector2 * result);
void fm2_mv_multiply_v(const FMatrix2 * const m, const FVector2 * const v, FVector2 * result);
void fm2_m_inverse_m(const FMatrix2 * const m1, FMatrix2 * m2);
float fm2_determinant(const FMatrix2 * const m);
FMatrix2 fm2_m_transposed(const FMatrix2 * const m);
FMatrix2 fm2_mm_add(const FMatrix2 * const m1, const FMatrix2 * const m2);
FMatrix2 fm2_mm_subtract(const FMatrix2 * const m1, const FMatrix2 * const m2);
FMatrix2 fm2_mm_multiply(const FMatrix2 * const m1, const FMatrix2 * const m2);
FVector2 fm2_vm_multiply(const FVector2 * const v, const FMatrix2 * const m);
FVector2 fm2_mv_multiply(const FMatrix2 * const m, const FVector2 * const v);
FMatrix2 fm2_m_inverse(const FMatrix2 * const m);
const char * fm2_m_to_string(FMatrix2 * m);

FMatrix3 * fm3_alloc(void);
FMatrix3 * fm3_alloc_init(void);
void fm3_free(FMatrix3 * v);
void fm3_m_set_identity(FMatrix3 * m);
void fm3_m_init_with_m3(FMatrix3 * m1, const struct Matrix3 * const m2);
void fm3_m_transpose_m(const FMatrix3 * const m, FMatrix3 * transpose);
void fm3_mm_add_m(const FMatrix3 * const m1, const FMatrix3 * const m2, FMatrix3 * result);
void fm3_mm_subtract_m(const FMatrix3 * const m1, const FMatrix3 * const m2, FMatrix3 * result);
void fm3_mm_multiply_m(const FMatrix3 * const m1, const FMatrix3 * const m2, FMatrix3 * result);
void fm3_vm_multiply_v(const FVector3 * const v, const FMatrix3 * const m, FVector3 * result);
void fm3_mv_multiply_v(const FMatrix3 * const m, const FVector3 * const v, FVector3 * result);
void fm3_m_inverse_m(const FMatrix3 * const m1, FMatrix3 * m2);
void fm3_m_get_right_vector_v(const FMatrix3 * const m, FVector3 * right);
void fm3_m_get_up_vector_v(const FMatrix3 * const m, FVector3 * up);
void fm3_m_get_forward_vector_v(const FMatrix3 * const m, FVector3 * forward);
void fm3_s_rotatex_m(float degree, FMatrix3 * result);
void fm3_s_rotatey_m(float degree, FMatrix3 * result);
void fm3_s_rotatez_m(float degree, FMatrix3 * result);
void fm3_s_scalex_m(float scale, FMatrix3 * result);
void fm3_s_scaley_m(float scale, FMatrix3 * result);
void fm3_s_scalez_m(float scale, FMatrix3 * result);
void fm3_s_scale_m(float scale, FMatrix3 * result);
float fm3_m_determinant(const FMatrix3 * const m);
FMatrix3 fm3_m_transposed(const FMatrix3 * const m);
FMatrix3 fm3_mm_add(const FMatrix3 * const m1, const FMatrix3 * const m2);
FMatrix3 fm3_mm_subtract(const FMatrix3 * const m1, const FMatrix3 * const m2);
FMatrix3 fm3_mm_multiply(const FMatrix3 * const m1, const FMatrix3 * const m2);
FVector3 fm3_vm_multiply(const FVector3 * const v, const FMatrix3 * const m);
FVector3 fm3_mv_multiply(const FMatrix3 * const m, const FVector3 * const v);
FMatrix3 fm3_m_inverse(const FMatrix3 * const m);
FVector3 fm3_m_get_right_vector(const FMatrix3 * const m);
FVector3 fm3_m_get_up_vector(const FMatrix3 * const m);
FVector3 fm3_m_get_forward_vector(const FMatrix3 * const m);
FMatrix3 fm3_s_rotatex(float degree);
FMatrix3 fm3_s_rotatey(float degree);
FMatrix3 fm3_s_rotatez(float degree);
FMatrix3 fm3_s_scalex(float scale);
FMatrix3 fm3_s_scaley(float scale);
FMatrix3 fm3_s_scalez(float scale);
FMatrix3 fm3_s_scale(float scale);
const char * fm3_m_to_string(FMatrix3 * m);

FMatrix4 * fm4_alloc(void);
FMatrix4 * fm4_alloc_init(void);
FMatrix4 * fm4_alloc_init_with_fm4(FMatrix4 * m);
void fm4_free(FMatrix4 * v);
void fm4_m_set_identity(FMatrix4 * m);
void fm4_m_init_with_m4(FMatrix4 * m1, const struct Matrix4 * const m2);
void fm4_m_init_with_fm4(FMatrix4 * destination, FMatrix4 * source);
void fm4_m_transpose_m(const FMatrix4 * const m, FMatrix4 * transpose);
void fm4_mm_add_m(const FMatrix4 * const m1, const FMatrix4 * const m2, FMatrix4 * result);
void fm4_mm_subtract_m(const FMatrix4 * const m1, const FMatrix4 * const m2, FMatrix4 * result);
void fm4_mm_multiply_m(const FMatrix4 * const m1, const FMatrix4 * const m2, FMatrix4 * result);
void fm4_vm_multiply_v(const FVector4 * const v, const FMatrix4 * const m, FVector4 * result);
void fm4_mv_multiply_v(const FMatrix4 * const m, const FVector4 * const v, FVector4 * result);
void fm4_mv_translation_matrix(FMatrix4 * m, const FVector3 * const v);
void fm4_mv_scale_matrix(FMatrix4 * m, const FVector3 * const v);
void fm4_ms_scale_matrix_x(FMatrix4 * m, float x);
void fm4_ms_scale_matrix_y(FMatrix4 * m, float y);
void fm4_ms_scale_matrix_z(FMatrix4 * m, float z);
void fm4_msss_scale_matrix_xyz(FMatrix4 * m, float x, float y, float z);
void fm4_vvv_look_at_matrix_m(const FVector3 * const eyePosition, const FVector3 * const lookAtPosition, const FVector3 * const upVector, FMatrix4 * result);
void fm4_vvvv_look_at_matrix_m(const FVector3 * const rightVector, const FVector3 * const upVector, const FVector3 * const forwardVector, const FVector3 * const position, FMatrix4 * result);
void fm4_mssss_projection_matrix(FMatrix4 * m, float aspectratio, float fovdegrees, float nearplane, float farplane);
void fm4_ms_simple_orthographic_projection_matrix(FMatrix4 * m, float aspectratio);
void fm4_mssssss_orthographic_projection_matrix(FMatrix4 * m, float left, float right, float bottom, float top, float near, float far);
void fm4_mssss_orthographic_2d_projection_matrix(FMatrix4 * m, float left, float right, float bottom, float top);
void fm4_mss_sub_matrix_m(const FMatrix4 * const m, const int row, const int column, FMatrix3 * result);
void fm4_m_inverse_m(const FMatrix4 * const m, FMatrix4 * result);
void fm4_m_get_right_vector_v(const FMatrix4 * const m, FVector3 * right);
void fm4_m_get_up_vector_v(const FMatrix4 * const m, FVector3 * up);
void fm4_m_get_forward_vector_v(const FMatrix4 * const m, FVector3 * forward);
void fm4_s_rotatex_m(float degree, FMatrix4 * result);
void fm4_s_rotatey_m(float degree, FMatrix4 * result);
void fm4_s_rotatez_m(float degree, FMatrix4 * result);
float fm4_m_determinant(const FMatrix4 * const m);
FMatrix4 fm4_m_transposed(const FMatrix4 * const m);
FMatrix4 fm4_mm_add(const FMatrix4 * const m1, const FMatrix4 * const m2);
FMatrix4 fm4_mm_subtract(const FMatrix4 * const m1, const FMatrix4 * const m2);
FMatrix4 fm4_mm_multiply(const FMatrix4 * const m1, const FMatrix4 * const m2);
FVector4 fm4_vm_multiply(const FVector4 * const v, const FMatrix4 * const m);
FVector4 fm4_mv_multiply(const FMatrix4 * const m, const FVector4 * const v);
FMatrix4 fm4_v_translation_matrix(const FVector3 * const v);
const char * fm4_m_to_string(FMatrix4 * m);

#endif
