#ifndef _NP_MATH_FPLANE_H_
#define _NP_MATH_FPLANE_H_

#include "Core/Basics/NpBasics.h"
#include "FVector.h"
#include "FRay.h"

void npmath_fplane_initialise();

typedef struct FPlane
{
    FVector3 normal;
    float    d;
}
FPlane;

FPlane * fplane_alloc();
FPlane * fplane_alloc_init();
FPlane * fplane_alloc_init_with_normal(const FVector3 * const normal);
FPlane * fplane_alloc_init_with_normal_and_scalar(const FVector3 * const normal, const float scalar);
FPlane * fplane_alloc_init_with_components(const float x, const float y, const float z, const float scalar);
void fplane_free(FPlane * p);
void fplane_pv_init_with_normal(FPlane * plane, const FVector3 * const normal);
void fplane_pvs_init_with_normal_and_scalar(FPlane * plane, const FVector3 * const normal, const float scalar);
void fplane_pssss_init_with_components(FPlane * plane, const float x, const float y, const float z, const float scalar);

int32_t fplane_pr_intersect_with_ray_v(const FPlane * const plane, const FRay * const ray, FVector3 * result);
float fplane_pv_signed_distance_from_plane(const FPlane * const plane, const FVector3 * const point);
float fplane_pv_distance_from_plane(const FPlane * const plane, const FVector3 * const point);

#endif
