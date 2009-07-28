#include "Ray.h"

NpFreeList * NP_RAY_FREELIST = NULL;

void npmath_ray_initialise()
{
    NPFREELIST_ALLOC_INIT(NP_RAY_FREELIST, Ray, 512);
}

Ray * ray_alloc()
{
    return npfreenode_alloc(NP_RAY_FREELIST);
}

Ray * ray_alloc_init()
{
    Ray * ray    = npfreenode_alloc(NP_RAY_FREELIST);
    v3_v_zeros(&(ray->point));
    v3_v_zeros(&(ray->direction));

    return ray;
}

Ray * ray_alloc_init_with_point_and_direction(Vector3 * point, Vector3 * direction)
{
    Ray * ray    = npfreenode_alloc(NP_RAY_FREELIST);
    ray->point     = *point;
    ray->direction = *direction;

    return ray;
}

Ray * ray_free(Ray * r)
{
    return npfreenode_free(r, NP_RAY_FREELIST);
}
