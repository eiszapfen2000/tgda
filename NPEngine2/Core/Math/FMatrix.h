#ifndef _NP_MATH_FMATRIX_H_
#define _NP_MATH_FMATRIX_H_

#include "Core/Basics/NpTypes.h"
#include "Accessors.h"
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

FMatrix2 * fm2_alloc();
FMatrix2 * fm2_alloc_init();
FMatrix2 * fm2_free(FMatrix2 * v);
void fm2_m_set_identity(FMatrix2 * m);
void fm2_m_transpose_m(const FMatrix2 * const m, FMatrix2 * transpose);
void fm2_mm_add_m(const FMatrix2 * const m1, const FMatrix2 * const m2, FMatrix2 * result);
void fm2_mm_subtract_m(const FMatrix2 * const m1, const FMatrix2 * const m2, FMatrix2 * result);
void fm2_mm_multiply_m(const FMatrix2 * const m1, const FMatrix2 * const m2, FMatrix2 * result);
void fm2_vm_multiply_v(const FVector2 * const v, const FMatrix2 * const m, FVector2 * result);
void fm2_mv_multiply_v(const FMatrix2 * const m, const FVector2 * const v, FVector2 * result);
void fm2_m_inverse_m(const FMatrix2 * const m1, FMatrix2 * m2);
Float fm2_determinant(const FMatrix2 * const m);
FMatrix2 fm2_m_transposed(const FMatrix2 const * m);
FMatrix2 fm2_mm_add(const FMatrix2 * const m1, const FMatrix2 * const m2);
FMatrix2 fm2_mm_subtract(const FMatrix2 * const m1, const FMatrix2 * const m2);
FMatrix2 fm2_mm_multiply(const FMatrix2 * const m1, const FMatrix2 * const m2);
FVector2 fm2_vm_multiply(const FVector2 * const v, const FMatrix2 * const m);
FVector2 fm2_mv_multiply(const FMatrix2 * const m, const FVector2 * const v);
FMatrix2 fm2_m_inverse(const FMatrix2 * const m);
const char * fm2_m_to_string(FMatrix2 * m);

FMatrix3 * fm3_alloc();
FMatrix3 * fm3_alloc_init();
FMatrix3 * fm3_free(FMatrix3 * v);
void fm3_m_set_identity(FMatrix3 * m);
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
void fm3_s_rotatex_m(Float degree, FMatrix3 * result);
void fm3_s_rotatey_m(Float degree, FMatrix3 * result);
void fm3_s_rotatez_m(Float degree, FMatrix3 * result);
void fm3_s_scalex_m(Float scale, FMatrix3 * result);
void fm3_s_scaley_m(Float scale, FMatrix3 * result);
void fm3_s_scalez_m(Float scale, FMatrix3 * result);
void fm3_s_scale_m(Float scale, FMatrix3 * result);
Float fm3_m_determinant(const FMatrix3 * const m);
FMatrix3 fm3_m_transposed(const FMatrix3 const * m);
FMatrix3 fm3_mm_add(const FMatrix3 * const m1, const FMatrix3 * const m2);
FMatrix3 fm3_mm_subtract(const FMatrix3 * const m1, const FMatrix3 * const m2);
FMatrix3 fm3_mm_multiply(const FMatrix3 * const m1, const FMatrix3 * const m2);
FVector3 fm3_vm_multiply(const FVector3 * const v, const FMatrix3 * const m);
FVector3 fm3_mv_multiply(const FMatrix3 * const m, const FVector3 * const v);
FMatrix3 fm3_m_inverse(const FMatrix3 * const m);
FVector3 fm3_m_get_right_vector(const FMatrix3 * const m);
FVector3 fm3_m_get_up_vector(const FMatrix3 * const m);
FVector3 fm3_m_get_forward_vector(const FMatrix3 * const m);
FMatrix3 fm3_s_rotatex(Float degree);
FMatrix3 fm3_s_rotatey(Float degree);
FMatrix3 fm3_s_rotatez(Float degree);
FMatrix3 fm3_s_scalex(Float scale);
FMatrix3 fm3_s_scaley(Float scale);
FMatrix3 fm3_s_scalez(Float scale);
FMatrix3 fm3_s_scale(Float scale);
const char * fm3_m_to_string(FMatrix3 * m);

FMatrix4 * fm4_alloc();
FMatrix4 * fm4_alloc_init();
FMatrix4 * fm4_alloc_init_with_fm4(FMatrix4 * m);
FMatrix4 * fm4_free(FMatrix4 * v);
void fm4_m_set_identity(FMatrix4 * m);
void fm4_m_init_with_fm4(FMatrix4 * destination, FMatrix4 * source);
void fm4_m_transpose_m(const FMatrix4 * const m, FMatrix4 * transpose);
void fm4_mm_add_m(const FMatrix4 * const m1, const FMatrix4 * const m2, FMatrix4 * result);
void fm4_mm_subtract_m(const FMatrix4 * const m1, const FMatrix4 * const m2, FMatrix4 * result);
void fm4_mm_multiply_m(const FMatrix4 * const m1, const FMatrix4 * const m2, FMatrix4 * result);
void fm4_vm_multiply_v(const FVector4 * const v, const FMatrix4 * const m, FVector4 * result);
void fm4_mv_multiply_v(const FMatrix4 * const m, const FVector4 * const v, FVector4 * result);
void fm4_mv_translation_matrix(FMatrix4 * m, const FVector3 * const v);
void fm4_mv_scale_matrix(FMatrix4 * m, const FVector3 * const v);
void fm4_ms_scale_matrix_x(FMatrix4 * m, Float x);
void fm4_ms_scale_matrix_y(FMatrix4 * m, Float y);
void fm4_ms_scale_matrix_z(FMatrix4 * m, Float z);
void fm4_msss_scale_matrix_xyz(FMatrix4 * m, Float x, Float y, Float z);
void fm4_vvv_look_at_matrix_m(FVector3 * eyePosition, FVector3 * lookAtPosition, FVector3 * upVector, FMatrix4 * result);
void fm4_vvvv_look_at_matrix_m(FVector3 * rightVector, FVector3 * upVector, FVector3 * forwardVector, FVector3 * position, FMatrix4 * result);
void fm4_mssss_projection_matrix(FMatrix4 * m, Float aspectratio, Float fovdegrees, Float nearplane, Float farplane);
void fm4_ms_simple_orthographic_projection_matrix(FMatrix4 * m, Float aspectratio);
void fm4_mssssss_orthographic_projection_matrix(FMatrix4 * m, Float left, Float right, Float bottom, Float top, Float near, Float far);
void fm4_mssss_orthographic_2d_projection_matrix(FMatrix4 * m, Float left, Float right, Float bottom, Float top);
void fm4_mss_sub_matrix_m(const FMatrix4 * const m, const int row, const int column, FMatrix3 * result);
void fm4_m_inverse_m(const FMatrix4 * const m, FMatrix4 * result);
void fm4_m_get_right_vector_v(const FMatrix4 * const m, FVector3 * right);
void fm4_m_get_up_vector_v(const FMatrix4 * const m, FVector3 * up);
void fm4_m_get_forward_vector_v(const FMatrix4 * const m, FVector3 * forward);
void fm4_s_rotatex_m(Float degree, FMatrix4 * result);
void fm4_s_rotatey_m(Float degree, FMatrix4 * result);
void fm4_s_rotatez_m(Float degree, FMatrix4 * result);
Float fm4_m_determinant(const FMatrix4 * const m);
FMatrix4 fm4_m_transposed(const FMatrix4 * const m);
FMatrix4 fm4_mm_add(const FMatrix4 * const m1, const FMatrix4 * const m2);
FMatrix4 fm4_mm_subtract(const FMatrix4 * const m1, const FMatrix4 * const m2);
FMatrix4 fm4_mm_multiply(const FMatrix4 * const m1, const FMatrix4 * const m2);
FVector4 fm4_vm_multiply(const FVector4 * const v, const FMatrix4 * const m);
FVector4 fm4_mv_multiply(const FMatrix4 * const m, const FVector4 * const v);
FMatrix4 fm4_v_translation_matrix(const FVector3 * const v);
const char * fm4_m_to_string(FMatrix4 * m);

#endif
