#ifndef _NP_MATH_FQUATERNION_H_
#define _NP_MATH_FQUATERNION_H_

#include "Core/Basics/NpTypes.h"
#include "Core/Basics/NpFreeList.h"
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
FQuaternion * fquat_alloc_init_with_axis_and_degrees(FVector3 * axis, Float * degrees);
FQuaternion * fquat_alloc_init_with_axis_and_radians(FVector3 * axis, Float * radians);
FQuaternion * fquat_free(FQuaternion * q);

void fquat_set_identity(FQuaternion * q);

void fquat_q_init_with_axis_and_degrees(FQuaternion * q, FVector3 * axis, Float * degrees);
void fquat_q_init_with_axis_and_radians(FQuaternion * q, FVector3 * axis, Float * radians);

void fquat_q_conjugate(FQuaternion * q);
void fquat_q_conjugate_q(const FQuaternion * const q, FQuaternion * conjugate);
void fquat_q_magnitude_s(const FQuaternion * const q, Float * s);
void fquat_q_normalise(FQuaternion * q);
void fquat_q_normalise_q(const FQuaternion * const q, FQuaternion * normalised);
void fquat_qq_multiply_q(const FQuaternion * const q1, const FQuaternion * const q2, FQuaternion * result);
void fquat_qv_multiply_v(const FQuaternion * const q, const FVector3 * const v, FVector3 * result);

void fquat_q_rotatex(FQuaternion * q, Float * degrees);
void fquat_q_rotatey(FQuaternion * q, Float * degrees);
void fquat_q_rotatez(FQuaternion * q, Float * degrees);

void fquat_q_forward_vector_v(FQuaternion * q, FVector3 * v);
void fquat_q_up_vector_v(FQuaternion * q, FVector3 * v);
void fquat_q_right_vector_v(FQuaternion * q, FVector3 * v);

void fquat_q_to_matrix3_m(const FQuaternion * const q, Matrix3 * m);
void fquat_q_to_fmatrix3_m(const FQuaternion * const q, FMatrix3 * m);
void fquat_q_to_matrix4_m(const FQuaternion * const q, Matrix4 * m);
void fquat_q_to_fmatrix4_m(const FQuaternion * const q, FMatrix4 * m);
void fquat_m3_to_FQuaternion_q(const FMatrix3 * const m, FQuaternion * q);
void fquat_m4_to_FQuaternion_q(const FMatrix4 * const m, FQuaternion * q);

Float fquat_q_magnitude(const FQuaternion * const q);

const char * fquat_q_to_string(FQuaternion * q);

#endif
