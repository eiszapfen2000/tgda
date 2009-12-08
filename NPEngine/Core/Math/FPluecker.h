#ifndef _NP_MATH_FPLUECKER_H_
#define _NP_MATH_FPLUECKER_H_

#include "FVector.h"
#include "FPlane.h"

void npmath_fpluecker_initialise();

typedef struct FPluecker
{
    FVector3 U;
    FVector3 V;
}
FPluecker;

FPluecker * fpluecker_alloc();
FPluecker * fpluecker_alloc_init();
FPluecker * fpluecker_alloc_init_with_points(const FVector3 const * p1, const FVector3 const * p2);
FPluecker * fpluecker_alloc_init_with_point_and_direction(const FVector3 const * point, const FVector3 const * direction);
FPluecker * fpluecker_free(FPluecker * p);

Int fpluecker_plp_intersect_with_plane_v(const FPluecker const * fpluecker, const FPlane const * p, FVector3 * result);

#endif
