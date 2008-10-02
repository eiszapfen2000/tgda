#ifndef _NP_MATH_PLANE_H_
#define _NP_MATH_PLANE_H_

#include "Core/Basics/NpBasics.h"
#include "Vector.h"
#include "Ray.h"

void npmath_plane_initialise();

typedef struct Plane
{
    Vector3 normal;
    Double  d;
}
Plane;

Plane * plane_alloc();
Plane * plane_alloc_init();
Plane * plane_alloc_init_with_normal(Vector3 * normal);
Plane * plane_alloc_init_with_normal_and_scalar(Vector3 * normal, Double scalar);
Plane * plane_free(Plane * p);

Int plane_pr_intersect_with_ray_v(Plane * plane, Ray * ray, Vector3 * result);
Double plane_pv_distance_from_plane_s(Plane * plane, Vector3 * point);

#endif
