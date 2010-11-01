#ifndef _NP_MATH_FRAY_H_
#define _NP_MATH_FRAY_H_

#include "Core/Basics/NpBasics.h"
#include "FVector.h"

void npmath_fray_initialise();

typedef struct FRay
{
    FVector3 point;
    FVector3 direction;
}
FRay;

FRay * fray_alloc();
FRay * fray_alloc_init();
FRay * fray_alloc_init_with_point_and_direction(const FVector3 * point, const FVector3 * direction);
FRay * fray_free(FRay * r);

#endif
