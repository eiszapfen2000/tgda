#include "FRay.h"

NpFreeList * NP_FRAY_FREELIST = NULL;

void npmath_fray_initialise()
{
    NPFREELIST_ALLOC_INIT(NP_FRAY_FREELIST,FRay,512);
}

FRay * fray_alloc()
{
    return npfreenode_alloc(NP_FRAY_FREELIST);
}

FRay * fray_alloc_init()
{
    FRay * ray    = npfreenode_alloc(NP_FRAY_FREELIST);
    fv3_v_zeros(&(ray->point));
    fv3_v_zeros(&(ray->direction));

    return ray;
}

FRay * fray_alloc_init_with_point_and_direction(FVector3 * point, FVector3 * direction)
{
    FRay * ray    = npfreenode_alloc(NP_FRAY_FREELIST);
    ray->point     = *point;
    ray->direction = *direction;

    return ray;
}

FRay * fray_free(FRay * r)
{
    return npfreenode_fast_free(r,NP_FRAY_FREELIST);
}
