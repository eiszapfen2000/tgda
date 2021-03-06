#define _GNU_SOURCE
#include <stdio.h>
#include "IRectangle.h"

#define MIN(_a,_b) ((_a < _b )? _a:_b)
#define MAX(_a,_b) ((_a > _b )? _a:_b)

NpFreeList * NP_IRECTANGLE_FREELIST = NULL;

void npmath_irectangle_initialise(void)
{
    NPFREELIST_ALLOC_INIT(NP_IRECTANGLE_FREELIST, IRectangle, 512);
}

IRectangle * irectangle_alloc(void)
{
    return npfreenode_alloc(NP_IRECTANGLE_FREELIST);
}

IRectangle * irectangle_alloc_init(void)
{
    IRectangle * rectangle = npfreenode_alloc(NP_IRECTANGLE_FREELIST);

    rectangle->min.x = rectangle->min.y = 0;
    rectangle->max.x = rectangle->max.y = 0;

    return rectangle;
}

void irectangle_free(IRectangle * r)
{
    npfreenode_free(r, NP_IRECTANGLE_FREELIST);
}

void irectangle_rssss_init_with_min_max(IRectangle * rectangle,
    const int32_t minX, const int32_t minY,
    const int32_t maxX, const int32_t maxY)
{
    rectangle->min.x = minX;
    rectangle->min.y = minY;
    rectangle->max.x = maxX;
    rectangle->max.y = maxY;    
}

void irectangle_rvv_init_with_min_max(IRectangle * rectangle,
    const IVector2 * const min,
    const IVector2 * const max)
{
    rectangle->min.x = min->x;
    rectangle->min.y = min->y;
    rectangle->max.x = max->x;
    rectangle->max.y = max->y;
}

void irectangle_rvv_init_with_min_and_size(IRectangle * rectangle,
    const IVector2 * const min,
    const IVector2 * const size)
{
    rectangle->min.x = min->x;
    rectangle->min.y = min->y;
    rectangle->max.x = min->x + size->x;
    rectangle->max.y = min->y + size->y;
}

void irectangle_r_recalculate_min_max(IRectangle * rectangle)
{
    int32_t minX = MIN(rectangle->min.x, rectangle->max.x);
    int32_t minY = MIN(rectangle->min.y, rectangle->max.y);
    int32_t maxX = MAX(rectangle->min.x, rectangle->max.x);
    int32_t maxY = MAX(rectangle->min.y, rectangle->max.y);

    rectangle->min.x = minX;
    rectangle->min.y = minY;
    rectangle->max.x = maxX;
    rectangle->max.y = maxY;
}

int32_t irectangle_r_calculate_width(const IRectangle * const rectangle)
{
    return rectangle->max.x - rectangle->min.x;
}

int32_t irectangle_r_calculate_height(const IRectangle * const rectangle)
{
    return rectangle->max.y - rectangle->min.y;
}

float irectangle_r_calculate_x_center(const IRectangle * const rectangle)
{
    return ((float)(rectangle->min.x)) + (rectangle->max.x - rectangle->min.x) * 0.5f;
}

float irectangle_r_calculate_y_center(const IRectangle * const rectangle)
{
    return ((float)(rectangle->min.y)) + (rectangle->max.y - rectangle->min.y) * 0.5f;
}

const char * irectangle_r_to_string(const IRectangle * const rectangle)
{
    char * irectanglestring;

    if ( asprintf(&irectanglestring, "Min (%d, %d) Max (%d, %d)",
                  rectangle->min.x, rectangle->min.y,
                  rectangle->max.x, rectangle->max.y) < 0)
    {
        return NULL;
    }

    return irectanglestring;
}
