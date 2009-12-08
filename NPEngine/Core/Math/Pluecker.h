#ifndef _NP_MATH_PLUECKER_H_
#define _NP_MATH_PLUECKER_H_

#include "Vector.h"
#include "Plane.h"

void npmath_pluecker_initialise();

typedef struct Pluecker
{
    Vector3 U;
    Vector3 V;
}
Pluecker;

Pluecker * pluecker_alloc();
Pluecker * pluecker_alloc_init();
Pluecker * pluecker_alloc_init_with_points(const Vector3 const * p1, const Vector3 const * p2);
Pluecker * pluecker_alloc_init_with_point_and_direction(const Vector3 const * point, const Vector3 const * direction);
Pluecker * pluecker_free(Pluecker * p);

Int pluecker_plp_intersect_with_plane_v(const Pluecker const * pluecker, const Plane const * p, Vector3 * result);

#endif
