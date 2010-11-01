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
FPlane * fplane_alloc_init_with_normal(const FVector3 * normal);
FPlane * fplane_alloc_init_with_normal_and_scalar(const FVector3 * normal, const Float scalar);
FPlane * fplane_alloc_init_with_components(const Float x, const Float y, const Float z, const Float scalar);
FPlane * fplane_free(FPlane * p);

int32_t fplane_pr_intersect_with_ray_v(const FPlane * plane, const FRay * ray, FVector3 * result);
Float fplane_pv_signed_distance_from_plane(const FPlane * plane, const FVector3 * point);
Float fplane_pv_distance_from_plane(const FPlane * plane, const FVector3 * point);

#endif
