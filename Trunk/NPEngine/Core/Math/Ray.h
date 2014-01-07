#ifndef _NP_MATH_RAY_H_
#define _NP_MATH_RAY_H_

#include "Core/Basics/NpBasics.h"
#include "Vector.h"

void npmath_ray_initialise();

typedef struct Ray
{
    Vector3 point;
    Vector3 direction;
}
Ray;

Ray * ray_alloc();
Ray * ray_alloc_init();
Ray * ray_alloc_init_with_point_and_direction(Vector3 * point, Vector3 * direction);
Ray * ray_free(Ray * r);

#endif
