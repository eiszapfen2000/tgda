#ifndef _NP_MATH_FQUATERNION_H_
#define _NP_MATH_FQUATERNION_H_

#include "Basics/Types.h"
#include "Basics/NpFreeList.h"
#include "FVector.h"

extern NpFreeList * NP_FQUATERNION_FREELIST;

void npmath_fquaternion_initialise();

typedef struct FQuaternion
{
    FVector3 v;
    Float  w;
}
FQuaternion;

#define FQUATERNION_V(_q)    (_q).v
#define FQUATERNION_X(_q)    (_q).v.x
#define FQUATERNION_Y(_q)    (_q).v.y
#define FQUATERNION_Z(_q)    (_q).v.z
#define FQUATERNION_W(_q)    (_q).w

#define FQ_V QUATERNION_V
#define FQ_X QUATERNION_X
#define FQ_Y QUATERNION_Y
#define FQ_Z QUATERNION_Z
#define FQ_W QUATERNION_W

void fquat_q_conjugate(FQuaternion * q);
void fquat_q_conjugate_q(const FQuaternion * const q, FQuaternion * conjugate);
void fquat_q_magnitude_s(const FQuaternion * const q, Float * s);
void fquat_q_normalise(FQuaternion * q);
void fquat_q_normalise_q(const FQuaternion * const q, FQuaternion * normalised);
void fquat_qq_multiply_q(const FQuaternion * const q1, const FQuaternion * const q2, FQuaternion * result);
Float fquat_q_magnitude(const FQuaternion * const q);

#endif
