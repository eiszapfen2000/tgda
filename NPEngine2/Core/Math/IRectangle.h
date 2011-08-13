#ifndef _NP_MATH_IRECTANGLE_H_
#define _NP_MATH_IRECTANGLE_H_

#include "Core/Basics/NpBasics.h"
#include "IVector.h"

void npmath_irectangle_initialise();

typedef struct IRectangle
{
    IVector2 min;
    IVector2 max;
}
IRectangle;

IRectangle * irectangle_alloc();
IRectangle * irectangle_alloc_init();
IRectangle * irectangle_free(IRectangle * r);

void irectangle_ssss_init_with_min_max_r(const int32_t minX, const int32_t minY,
    const int32_t maxX, const int32_t maxY, IRectangle * rectangle);
void irectangle_vv_init_with_min_max_r(const IVector2 const * min,
    const IVector2 const * max, IRectangle * rectangle);
void irectangle_vv_init_with_min_and_size_r(const IVector2 const * min,
    const IVector2 const * size, IRectangle * rectangle);
void irectangle_r_recalculate_min_max(IRectangle * rectangle);
int32_t irectangle_r_calculate_width(const IRectangle const * rectangle);
int32_t irectangle_r_calculate_height(const IRectangle const * rectangle);
float irectangle_r_calculate_x_center(const IRectangle const * rectangle);
float irectangle_r_calculate_y_center(const IRectangle const * rectangle);
const char * irectangle_r_to_string(const IRectangle const * rectangle);

#endif
