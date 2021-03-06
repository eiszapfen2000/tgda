#define _GNU_SOURCE
#include <stdio.h>
#include "Core/Basics/NpFreeList.h"
#include "FRectangle.h"

#ifndef MIN
#define MIN(_a,_b) ((_a < _b )? _a:_b)
#endif

#ifndef MAX
#define MAX(_a,_b) ((_a > _b )? _a:_b)
#endif

NpFreeList * NP_FRECTANGLE_FREELIST = NULL;

void npmath_frectangle_initialise(void)
{
    NPFREELIST_ALLOC_INIT(NP_FRECTANGLE_FREELIST, FRectangle, 512);
}

FRectangle * frectangle_alloc(void)
{
    return npfreenode_alloc(NP_FRECTANGLE_FREELIST);
}

FRectangle * frectangle_alloc_init(void)
{
    FRectangle * rectangle = npfreenode_alloc(NP_FRECTANGLE_FREELIST);

    rectangle->min.x = rectangle->min.y = 0.0f;
    rectangle->max.x = rectangle->max.y = 0.0f;

    return rectangle;
}

void frectangle_free(FRectangle * r)
{
    npfreenode_free(r, NP_FRECTANGLE_FREELIST);
}

void frectangle_rssss_init_with_min_max(FRectangle * rectangle,
    const float minX, const float minY,
    const float maxX, const float maxY)
{
    rectangle->min.x = minX;
    rectangle->min.y = minY;
    rectangle->max.x = maxX;
    rectangle->max.y = maxY;
}

void frectangle_rvv_init_with_min_max(FRectangle * rectangle,
    const FVector2 * const min,
    const FVector2 * const max)
{
    rectangle->min.x = min->x;
    rectangle->min.y = min->y;
    rectangle->max.x = max->x;
    rectangle->max.y = max->y;
}

void frectangle_rvv_init_with_min_and_size(FRectangle * rectangle,
    const FVector2 * const min,
    const FVector2 * const size)
{
    rectangle->min.x = min->x;
    rectangle->min.y = min->y;
    rectangle->max.x = min->x + size->x;
    rectangle->max.y = min->y + size->y;
}

void frectangle_r_recalculate_min_max(FRectangle * rectangle)
{
    float minX = MIN(rectangle->min.x, rectangle->max.x);
    float minY = MIN(rectangle->min.y, rectangle->max.y);
    float maxX = MAX(rectangle->min.x, rectangle->max.x);
    float maxY = MAX(rectangle->min.y, rectangle->max.y);

    rectangle->min.x = minX;
    rectangle->min.y = minY;
    rectangle->max.x = maxX;
    rectangle->max.y = maxY;
}

float frectangle_r_calculate_width(const FRectangle * const rectangle)
{
    return rectangle->max.x - rectangle->min.x;
}

float frectangle_r_calculate_height(const FRectangle * const rectangle)
{
    return rectangle->max.y - rectangle->min.y;
}

float frectangle_r_calculate_x_center(const FRectangle * const rectangle)
{
    return rectangle->min.x + (rectangle->max.x - rectangle->min.x) * 0.5f;
}

float frectangle_r_calculate_y_center(const FRectangle * const rectangle)
{
    return rectangle->min.y + (rectangle->max.y - rectangle->min.y) * 0.5f;
}

void frectangle_r_calculate_center_v(const FRectangle * const rectangle, FVector2 * result)
{
    result->x = frectangle_r_calculate_x_center(rectangle);
    result->y = frectangle_r_calculate_y_center(rectangle);
}

int32_t frectangle_vr_is_point_inside(const FVector2 * const point,
    const FRectangle * const rectangle)
{
    int32_t result = 0;

    if ( point->x > rectangle->min.x && point->x < rectangle->max.x &&
         point->y > rectangle->min.y && point->y < rectangle->max.y )
    {
        result = 1;
    }

    return result;
}

const char * frectangle_r_to_string(const FRectangle * const rectangle)
{
    char * frectanglestring;

    if ( asprintf(&frectanglestring, "Min (%f, %f) Max (%f, %f)",
                  rectangle->min.x, rectangle->min.y,
                  rectangle->max.x, rectangle->max.y) < 0)
    {
        return NULL;
    }

    return frectanglestring;
}
