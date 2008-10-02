#ifndef _NP_MATH_FPLANE_H_
#define _NP_MATH_FPLANE_H_

#include "Core/Basics/NpBasics.h"
#include "FVector.h"
#include "FRay.h"

void npmath_fplane_initialise();

typedef struct FPlane
{
    FVector3 normal;
    Float    d;
}
FPlane;

FPlane * fplane_alloc();
FPlane * fplane_alloc_init();
FPlane * fplane_alloc_init_with_normal(FVector3 * normal);
FPlane * fplane_alloc_init_with_normal_and_scalar(FVector3 * normal, Float scalar);
FPlane * fplane_free(FPlane * p);

Int fplane_pr_intersect_with_ray_v(FPlane * plane, FRay * ray, FVector3 * result);
Float fplane_pv_distance_from_plane_s(FPlane * plane, FVector3 * point);

#endif
