#ifndef _NP_MATH_PLANE_H_
#define _NP_MATH_PLANE_H_

#include "Core/Basics/NpBasics.h"
#include "Vector.h"
#include "Ray.h"

void npmath_plane_initialise(void);

typedef struct Plane
{
    Vector3 normal;
    double  d;
}
Plane;

Plane * plane_alloc(void);
Plane * plane_alloc_init(void);
Plane * plane_alloc_init_with_normal(Vector3 * normal);
Plane * plane_alloc_init_with_normal_and_scalar(Vector3 * normal, double scalar);
void plane_free(Plane * p);
void plane_pv_init_with_normal(Plane * plane, const Vector3 * const normal);
void plane_pvs_init_with_normal_and_scalar(Plane * plane, const Vector3 * const normal, const double scalar);
void plane_pssss_init_with_components(Plane * plane, const double x, const double y, const double z, const double scalar);

int32_t plane_pr_intersect_with_ray_v(Plane * plane, Ray * ray, Vector3 * result);
double plane_pv_signed_distance_from_plane(const Plane * const plane, const Vector3 * const point);
double plane_pv_distance_from_plane(Plane * plane, Vector3 * point);

#endif
