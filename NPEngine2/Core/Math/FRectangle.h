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

void frectangle_ssss_init_with_min_max_r(float minX, float minY, float maxX, float maxY, FRectangle * rectangle);
void frectangle_vv_init_with_min_max_r(FVector2 * min, FVector2 * max, FRectangle * rectangle);
void frectangle_vv_init_with_min_and_size_r(FVector2 * min, FVector2 * size, FRectangle * rectangle);
void frectangle_r_recalculate_min_max(FRectangle * rectangle);
Float frectangle_r_calculate_width(FRectangle * rectangle);
Float frectangle_r_calculate_height(FRectangle * rectangle);
Float frectangle_r_calculate_x_center(FRectangle * rectangle);
Float frectangle_r_calculate_y_center(FRectangle * rectangle);
void frectangle_r_calculate_center_v(FRectangle * rectangle, FVector2 * result);
int32_t frectangle_vr_is_point_inside(FVector2 * point, FRectangle * rectangle);
const char * frectangle_r_to_string(FRectangle * rectangle);

#endif
