#ifndef _NP_MATH_PLUECKER_H_
#define _NP_MATH_PLUECKER_H_

#include "Vector.h"
#include "Plane.h"

void npmath_pluecker_initialise(void);

typedef struct Pluecker
{
    Vector3 U;
    Vector3 V;
}
Pluecker;

Pluecker * pluecker_alloc(void);
Pluecker * pluecker_alloc_init(void);
Pluecker * pluecker_alloc_init_with_points(const Vector3 * const p1, const Vector3 * const p2);
Pluecker * pluecker_alloc_init_with_point_and_direction(const Vector3 * const point, const Vector3 * const direction);
void pluecker_free(Pluecker * p);
void pluecker_init_with_points(Pluecker * pl, const Vector3 * const p1, const Vector3 * const p2);
void pluecker_init_with_point_and_direction(Pluecker * pl, const Vector3 * const point, const Vector3 * const direction);

int32_t pluecker_plp_intersect_with_plane_v(const Pluecker * const pluecker, const Plane * const p, Vector3 * result);

#endif
