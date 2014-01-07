#ifndef _NP_MATH_QUATERNION_H_
#define _NP_MATH_QUATERNION_H_

#include "Core/Basics/NpTypes.h"
#include "Core/Basics/NpFreeList.h"
#include "Accessors.h"
#include "Vector.h"
#include "Matrix.h"
#include "FMatrix.h"

void npmath_quaternion_initialise();

typedef struct
{
    Vector3 v;
    Double  w;
}
Quaternion;

Quaternion * quat_alloc();
Quaternion * quat_alloc_init();
Quaternion * quat_alloc_init_with_axis_and_degrees(Vector3 * axis, Double * degrees);
Quaternion * quat_alloc_init_with_axis_and_radians(Vector3 * axis, Double * radians);
Quaternion * quat_free(Quaternion * q);

void quat_set_identity(Quaternion * q);

void quat_q_init_with_axis_and_degrees(Quaternion * q, Vector3 * axis, Double * degrees);
void quat_q_init_with_axis_and_radians(Quaternion * q, Vector3 * axis, Double * radians);

void quat_q_conjugate(Quaternion * q);
void quat_q_conjugate_q(const Quaternion * const q, Quaternion * conjugate);
void quat_q_magnitude_s(const Quaternion * const q, Double * s);
void quat_q_normalise(Quaternion * q);
void quat_q_normalise_q(const Quaternion * const q, Quaternion * normalised);
void quat_qq_multiply_q(const Quaternion * const q1, const Quaternion * const q2, Quaternion * result);
void quat_qv_multiply_v(const Quaternion * const q, const Vector3 * const v, Vector3 * result);

void quat_q_rotatex(Quaternion * q, Double * degrees);
void quat_q_rotatey(Quaternion * q, Double * degrees);
void quat_q_rotatez(Quaternion * q, Double * degrees);

void quat_q_forward_vector_v(Quaternion * q, Vector3 * v);
void quat_q_up_vector_v(Quaternion * q, Vector3 * v);
void quat_q_right_vector_v(Quaternion * q, Vector3 * v);

void quat_q_to_matrix3_m(const Quaternion * const q, Matrix3 * m);
void quat_q_to_fmatrix3_m(const Quaternion * const q, FMatrix3 * m);
void quat_q_to_matrix4_m(const Quaternion * const q, Matrix4 * m);
void quat_q_to_fmatrix4_m(const Quaternion * const q, FMatrix4 * m);
void quat_m3_to_quaternion_q(const Matrix3 * const m, Quaternion * q);
void quat_m4_to_quaternion_q(const Matrix4 * const m, Quaternion * q);

Double quat_q_magnitude(const Quaternion * const q);

Quaternion quat_q_conjugated(const Quaternion * const q);
Quaternion quat_q_normalised(const Quaternion * const q);
Quaternion quat_qq_multiply(const Quaternion * const q1, const Quaternion * const q2);
Vector3 quat_qv_multiply(const Quaternion * const q, const Vector3 * const v);

Vector3 quat_q_forward_vector(const Quaternion * const q);
Vector3 quat_q_up_vector(const Quaternion * const q);
Vector3 quat_q_right_vector(const Quaternion * const q);

Matrix3 quat_q_to_matrix3(const Quaternion * const q);
FMatrix3 quat_q_to_fmatrix3(const Quaternion * const q);
Matrix4 quat_q_to_matrix4(const Quaternion * const q);
FMatrix4 quat_q_to_fmatrix4(const Quaternion * const q);
Quaternion quat_m3_to_quaternion(const Matrix3 * const m);
Quaternion quat_m4_to_quaternion(const Matrix4 * const m);

const char * quat_q_to_string(Quaternion * q);

#endif
