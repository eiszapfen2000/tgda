#ifndef _NP_MATH_FRECTANGLE_H_
#define _NP_MATH_FRECTANGLE_H_

#include "Core/Basics/NpBasics.h"
#include "FVector.h"

void npmath_frectangle_initialise();

typedef struct FRectangle
{
    FVector2 min;
    FVector2 max;
}
FRectangle;

FRectangle * frectangle_alloc();
FRectangle * frectangle_alloc_init();
FRectangle * frectangle_free(FRectangle * r);
void frectangle_vv_init_with_min_max_r(FVector2 * min, FVector2 * max, FRectangle * rectangle);
void frectangle_vv_init_with_min_and_size_r(FVector2 * min, FVector2 * size, FRectangle * rectangle);
Int32 frectangle_vr_is_point_inside(FVector2 * point, FRectangle * rectangle);
const char * frectangle_r_to_string(FRectangle * rectangle);

#endif
