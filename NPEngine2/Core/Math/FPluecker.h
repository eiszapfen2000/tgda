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
FPluecker * fpluecker_alloc_init_with_points(const FVector3 * p1, const FVector3 * p2);
FPluecker * fpluecker_alloc_init_with_point_and_direction(const FVector3 * point, const FVector3 *  direction);
void fpluecker_free(FPluecker * p);

void fpluecker_init_with_points(FPluecker * pl, const FVector3 * p1, const FVector3 * p2);
void fpluecker_init_with_point_and_direction(FPluecker * pl, const FVector3 * point, const FVector3 * direction);

int32_t fpluecker_plp_intersect_with_plane_v(const FPluecker * fpluecker, const FPlane * p, FVector3 * result);

#endif
