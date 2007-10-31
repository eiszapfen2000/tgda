#ifndef _NP_MATH_QUATERNION_H_
#define _NP_MATH_QUATERNION_H_

#include "Basics/Types.h"
#include "Basics/NpFreeList.h"
#include "Vector.h"
#include "Matrix.h"

extern NpFreeList * NP_QUATERNION_FREELIST;

void npmath_quaternion_initialise();

typedef struct
{
    Vector3 v;
    Double  w;
}
Quaternion;

#define QUATERNION_V(_q)    (_q).v
#define QUATERNION_X(_q)    (_q).v.x
#define QUATERNION_Y(_q)    (_q).v.y
#define QUATERNION_Z(_q)    (_q).v.z
#define QUATERNION_W(_q)    (_q).w

#define Q_V QUATERNION_V
#define Q_X QUATERNION_X
#define Q_Y QUATERNION_Y
#define Q_Z QUATERNION_Z
#define Q_W QUATERNION_W

void quat_q_conjugate(Quaternion * q);
void quat_q_conjugate_q(const Quaternion * const q, Quaternion * conjugate);
void quat_q_magnitude_s(const Quaternion * const q, Double * s);
void quat_q_normalise(Quaternion * q);
void quat_q_normalise_q(const Quaternion * const q, Quaternion * normalised);
void quat_qq_multiply_q(const Quaternion * const q1, const Quaternion * const q2, Quaternion * result);
void quat_q_to_matrix3_m(const Quaternion * const q, Matrix3 * m);
void quat_q_to_matrix4_m(const Quaternion * const q, Matrix4 * m);
Double quat_q_magnitude(const Quaternion * const q);

#endif
