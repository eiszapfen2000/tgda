#ifndef _NP_MATH_FRECTANGLE_H_
#define _NP_MATH_FRECTANGLE_H_

#include "Core/Basics/NpTypes.h"
#include "FVector.h"

void npmath_frectangle_initialise(void);

typedef struct FRectangle
{
    FVector2 min;
    FVector2 max;
}
FRectangle;

FRectangle * frectangle_alloc(void);
FRectangle * frectangle_alloc_init(void);
void frectangle_free(FRectangle * r);

void frectangle_rssss_init_with_min_max(FRectangle * rectangle,
    const float minX, const float minY,
    const float maxX, const float maxY);

void frectangle_rvv_init_with_min_max(FRectangle * rectangle,
    const FVector2 * const min,
    const FVector2 * const max);

void frectangle_rvv_init_with_min_and_size(FRectangle * rectangle,
    const FVector2 * const min,
    const FVector2 * const size);

void frectangle_r_recalculate_min_max(FRectangle * rectangle);
float frectangle_r_calculate_width(const FRectangle * const rectangle);
float frectangle_r_calculate_height(const FRectangle * const rectangle);
float frectangle_r_calculate_x_center(const FRectangle * const rectangle);
float frectangle_r_calculate_y_center(const FRectangle * const rectangle);
void frectangle_r_calculate_center_v(const FRectangle * const rectangle, FVector2 * result);

int32_t frectangle_vr_is_point_inside(const FVector2 * const point,
    const FRectangle * const rectangle);

const char * frectangle_r_to_string(const FRectangle * const rectangle);

#endif
