#include "FRay.h"

NpFreeList * NP_FRAY_FREELIST = NULL;

void npmath_fray_initialise(void)
{
    NPFREELIST_ALLOC_INIT(NP_FRAY_FREELIST, FRay, 512);
}

FRay * fray_alloc(void)
{
    return npfreenode_alloc(NP_FRAY_FREELIST);
}

FRay * fray_alloc_init(void)
{
    FRay * ray    = npfreenode_alloc(NP_FRAY_FREELIST);
    fv3_v_init_with_zeros(&(ray->point));
    fv3_v_init_with_zeros(&(ray->direction));

    return ray;
}

FRay * fray_alloc_init_with_point_and_direction(const FVector3 * point, const FVector3 * direction)
{
    FRay * ray    = npfreenode_alloc(NP_FRAY_FREELIST);
    ray->point     = *point;
    ray->direction = *direction;

    return ray;
}

void fray_free(FRay * r)
{
    npfreenode_free(r, NP_FRAY_FREELIST);
}
