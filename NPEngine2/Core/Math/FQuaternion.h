#ifndef _NP_MATH_FQUATERNION_H_
#define _NP_MATH_FQUATERNION_H_

#include "Core/Basics/NpTypes.h"
#include "Accessors.h"
#include "FVector.h"
#include "Matrix.h"
#include "FMatrix.h"

void npmath_fquaternion_initialise(void);

typedef struct FQuaternion
{
    FVector3 v;
    float    w;
}
FQuaternion;

FQuaternion * fquat_alloc(void);
FQuaternion * fquat_alloc_init(void);
FQuaternion * fquat_alloc_init_with_axis_and_degrees(const FVector3 * const axis, const float degrees);
FQuaternion * fquat_alloc_init_with_axis_and_radians(const FVector3 * const axis, const float radians);
void fquat_free(FQuaternion * q);

void fquat_set_identity(FQuaternion * q);
void fquat_q_init_with_axis_and_degrees(FQuaternion * q, const FVector3 * const axis, const float degrees);
void fquat_q_init_with_axis_and_radians(FQuaternion * q, const FVector3 * const axis, const float radians);

void fquat_q_conjugate(FQuaternion * q);
void fquat_q_conjugate_q(const FQuaternion * const q, FQuaternion * conjugate);
void fquat_q_normalise(FQuaternion * q);
void fquat_q_normalise_q(const FQuaternion * const q, FQuaternion * normalised);
void fquat_qq_multiply_q(const FQuaternion * const q1, const FQuaternion * const q2, FQuaternion * result);
void fquat_qv_multiply_v(const FQuaternion * const q, const FVector3 * const v, FVector3 * result);

void fquat_q_rotatex(FQuaternion * q, const float degrees);
void fquat_q_rotatey(FQuaternion * q, const float degrees);
void fquat_q_rotatez(FQuaternion * q, const float degrees);

void fquat_q_forward_vector_v(const FQuaternion * const q, FVector3 * v);
void fquat_q_up_vector_v(const FQuaternion * const q, FVector3 * v);
void fquat_q_right_vector_v(const FQuaternion * const q, FVector3 * v);

void fquat_q_to_matrix3_m(const FQuaternion * const q, Matrix3 * m);
void fquat_q_to_fmatrix3_m(const FQuaternion * const q, FMatrix3 * m);
void fquat_q_to_matrix4_m(const FQuaternion * const q, Matrix4 * m);
void fquat_q_to_fmatrix4_m(const FQuaternion * const q, FMatrix4 * m);
void fquat_m3_to_quaternion_q(const FMatrix3 * const m, FQuaternion * q);
void fquat_m4_to_quaternion_q(const FMatrix4 * const m, FQuaternion * q);

void fquat_qqs_slerp_q(const FQuaternion * const q1, const FQuaternion * const q2, const float u, FQuaternion * result);

float fquat_q_magnitude(const FQuaternion * const q);

FQuaternion fquat_q_conjugated(const FQuaternion * const q);
FQuaternion fquat_q_normalised(const FQuaternion * const q);
FQuaternion fquat_qq_multiply(const FQuaternion * const q1, const FQuaternion * const q2);
FVector3 fquat_qv_multiply(const FQuaternion * const q, const FVector3 * const v);

FVector3 fquat_q_forward_vector(const FQuaternion * const q);
FVector3 fquat_q_up_vector(const FQuaternion * const q);
FVector3 fquat_q_right_vector(const FQuaternion * const q);

Matrix3 fquat_q_to_matrix3(const FQuaternion * const q);
FMatrix3 fquat_q_to_fmatrix3(const FQuaternion * const q);
Matrix4 fquat_q_to_matrix4(const FQuaternion * const q);
FMatrix4 fquat_q_to_fmatrix4(const FQuaternion * const q);
FQuaternion fquat_m3_to_quaternion(const FMatrix3 * const m);
FQuaternion fquat_m4_to_quaternion(const FMatrix4 * const m);

FQuaternion fquat_qqs_slerp(const FQuaternion * const q1, const FQuaternion * const q2, const float u);

const char * fquat_q_to_string(const FQuaternion * const q);

#endif
