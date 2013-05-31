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
void frectangle_free(FRectangle * r);

void frectangle_ssss_init_with_min_max_r(const float minX, const float minY,
    const float maxX, const float maxY, FRectangle * rectangle);

void frectangle_vv_init_with_min_max_r(const FVector2 const * min,
    const FVector2 const * max, FRectangle * rectangle);

void frectangle_vv_init_with_min_and_size_r(const FVector2 const * min,
    const FVector2 const * size, FRectangle * rectangle);

void frectangle_r_recalculate_min_max(FRectangle * rectangle);
Float frectangle_r_calculate_width(const FRectangle const * rectangle);
Float frectangle_r_calculate_height(const FRectangle const * rectangle);
Float frectangle_r_calculate_x_center(const FRectangle const * rectangle);
Float frectangle_r_calculate_y_center(const FRectangle const * rectangle);
void frectangle_r_calculate_center_v(const FRectangle const * rectangle, FVector2 * result);

int32_t frectangle_vr_is_point_inside(const FVector2 const * point,
    const FRectangle const * rectangle);

const char * frectangle_r_to_string(const FRectangle const * rectangle);

#endif
