#ifndef _NP_MATH_FQUATERNION_H_
#define _NP_MATH_FQUATERNION_H_

#include "Core/Basics/NpTypes.h"
#include "Accessors.h"
#include "FVector.h"
#include "Matrix.h"
#include "FMatrix.h"

void npmath_fquaternion_initialise();

typedef struct FQuaternion
{
    FVector3 v;
    Float    w;
}
FQuaternion;

FQuaternion * fquat_alloc();
FQuaternion * fquat_alloc_init();
FQuaternion * fquat_alloc_init_with_axis_and_degrees(const FVector3 * axis, const Float degrees);
FQuaternion * fquat_alloc_init_with_axis_and_radians(const FVector3 * axis, const Float radians);
FQuaternion * fquat_free(FQuaternion * q);

void fquat_set_identity(FQuaternion * q);

void fquat_q_init_with_axis_and_degrees(FQuaternion * q, const FVector3 * axis, const Float degrees);
void fquat_q_init_with_axis_and_radians(FQuaternion * q, const FVector3 * axis, const Float radians);

void fquat_q_conjugate(FQuaternion * q);
void fquat_q_conjugate_q(const FQuaternion * restrict q, FQuaternion * restrict conjugate);
void fquat_q_normalise(FQuaternion * q);
void fquat_q_normalise_q(const FQuaternion * restrict q, FQuaternion * restrict normalised);
void fquat_qq_multiply_q(const FQuaternion * restrict q1, const FQuaternion * restrict q2, FQuaternion * restrict result);
void fquat_qv_multiply_v(const FQuaternion * q, const FVector3 * restrict v, FVector3 * restrict result);

void fquat_q_rotatex(FQuaternion * q, const Float degrees);
void fquat_q_rotatey(FQuaternion * q, const Float degrees);
void fquat_q_rotatez(FQuaternion * q, const Float degrees);

void fquat_q_forward_vector_v(const FQuaternion * q, FVector3 * v);
void fquat_q_up_vector_v(const FQuaternion * q, FVector3 * v);
void fquat_q_right_vector_v(const FQuaternion * q, FVector3 * v);

void fquat_q_to_matrix3_m(const FQuaternion * q, Matrix3 * m);
void fquat_q_to_fmatrix3_m(const FQuaternion * q, FMatrix3 * m);
void fquat_q_to_matrix4_m(const FQuaternion * q, Matrix4 * m);
void fquat_q_to_fmatrix4_m(const FQuaternion * q, FMatrix4 * m);
void fquat_m3_to_quaternion_q(const FMatrix3 * m, FQuaternion * q);
void fquat_m4_to_quaternion_q(const FMatrix4 * m, FQuaternion * q);

FQuaternion fquat_q_conjugated(const FQuaternion * q);
FQuaternion fquat_q_normalised(const FQuaternion * q);
FQuaternion fquat_qq_multiply(const FQuaternion * restrict q1, const FQuaternion * restrict q2);
FVector3 fquat_qv_multiply(const FQuaternion * q, const FVector3 * v);

FVector3 fquat_q_forward_vector(const FQuaternion * q);
FVector3 fquat_q_up_vector(const FQuaternion * q);
FVector3 fquat_q_right_vector(const FQuaternion * q);

Matrix3 fquat_q_to_matrix3(const FQuaternion * const q);
FMatrix3 fquat_q_to_fmatrix3(const FQuaternion * const q);
Matrix4 fquat_q_to_matrix4(const FQuaternion * const q);
FMatrix4 fquat_q_to_fmatrix4(const FQuaternion * const q);
FQuaternion fquat_m3_to_quaternion(const FMatrix3 * const m);
FQuaternion fquat_m4_to_quaternion(const FMatrix4 * const m);

const char * fquat_q_to_string(const FQuaternion * q);

#endif
