#include "FRectangle.h"

NpFreeList * NP_FRECTANGLE_FREELIST = NULL;

void npmath_frectangle_initialise()
{
    NPFREELIST_ALLOC_INIT(NP_FRECTANGLE_FREELIST, FRectangle, 512);
}

FRectangle * frectangle_alloc()
{
    return npfreenode_alloc(NP_FRECTANGLE_FREELIST);
}

FRectangle * frectangle_alloc_init()
{
    FRectangle * rectangle = npfreenode_alloc(NP_FRECTANGLE_FREELIST);

    rectangle->min.x = rectangle->min.y = 0.0f;
    rectangle->max.x = rectangle->max.y = 0.0f;

    return rectangle;
}

FRectangle * frectangle_free(FRectangle * r)
{
    return npfreenode_free(r, NP_FRECTANGLE_FREELIST);
}

void frectangle_vv_init_with_min_max_r(FVector2 * min, FVector2 * max, FRectangle * rectangle)
{
    rectangle->min.x = min->x;
    rectangle->min.y = min->y;
    rectangle->max.x = max->x;
    rectangle->max.y = max->y;
}

void frectangle_vv_init_with_min_and_size_r(FVector2 * min, FVector2 * size, FRectangle * rectangle)
{
    rectangle->min.x = min->x;
    rectangle->min.y = min->y;
    rectangle->max.x = min->x + size->x;
    rectangle->max.y = min->y + size->y;
}

Int32 frectangle_vr_is_point_inside(FVector2 * point, FRectangle * rectangle)
{
    Int32 result = 0;

    if ( point->x > rectangle->min.x && point->x < rectangle->max.x &&
         point->y > rectangle->min.y && point->y < rectangle->max.y )
    {
        result = 1;
    }

    return result;
}

const char * frectangle_r_to_string(FRectangle * rectangle)
{
    char * frectanglestring;

    if ( asprintf(&frectanglestring, "Min (%f, %f) Max (%f, %f)",rectangle->min.x, rectangle->min.y, rectangle->max.x, rectangle->max.y) < 0)
    {
        return NULL;
    }

    return frectanglestring;
}
