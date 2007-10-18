#ifndef _NP_MATH_QUATERNION_H_
#define _NP_MATH_QUATERNION_H_

#include "Basics/Types.h"
#include "Vector.h"

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
void quat_q_conjugate_q(Quaternion * q, Quaternion * conjugate);

Double quat_q_magnitude(Quaternion * q);
void quat_q_magnitude_s(Quaternion * q, Double * s);

void quat_q_normalise(Quaternion * q);
void quat_q_normalise_q(Quaternion * q, Quaternion * normalised);

void quat_qq_multiply_q(Quaternion * q1, Quaternion * q2, Quaternion * result);

#endif
