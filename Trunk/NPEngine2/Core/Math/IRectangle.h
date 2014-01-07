#ifndef _NP_MATH_IRECTANGLE_H_
#define _NP_MATH_IRECTANGLE_H_

#include "Core/Basics/NpBasics.h"
#include "IVector.h"

void npmath_irectangle_initialise(void);

typedef struct IRectangle
{
    IVector2 min;
    IVector2 max;
}
IRectangle;

IRectangle * irectangle_alloc(void);
IRectangle * irectangle_alloc_init(void);
void irectangle_free(IRectangle * r);

void irectangle_rssss_init_with_min_max(IRectangle * rectangle,
    const int32_t minX, const int32_t minY,
    const int32_t maxX, const int32_t maxY);

void irectangle_rvv_init_with_min_max(IRectangle * rectangle,
    const IVector2 * const min,
    const IVector2 * const max);

void irectangle_rvv_init_with_min_and_size(IRectangle * rectangle,
    const IVector2 * const min,
    const IVector2 * const size);

void irectangle_r_recalculate_min_max(IRectangle * rectangle);
int32_t irectangle_r_calculate_width(const IRectangle * const rectangle);
int32_t irectangle_r_calculate_height(const IRectangle * const rectangle);
float irectangle_r_calculate_x_center(const IRectangle * const rectangle);
float irectangle_r_calculate_y_center(const IRectangle * const rectangle);
const char * irectangle_r_to_string(const IRectangle * const rectangle);

#endif
