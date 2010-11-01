#include <math.h>

#include "Plane.h"
#include "Constants.h"

NpFreeList * NP_PLANE_FREELIST = NULL;

void npmath_plane_initialise()
{
    NPFREELIST_ALLOC_INIT(NP_PLANE_FREELIST, Plane, 512);
}

Plane * plane_alloc()
{
    return npfreenode_alloc(NP_PLANE_FREELIST);
}

Plane * plane_alloc_init()
{
    Plane * plane   = npfreenode_alloc(NP_PLANE_FREELIST);
    plane->normal.x = plane->normal.y = plane->normal.z = 0.0;
    plane->d        = 0.0;

    return plane;
}

Plane * plane_alloc_init_with_normal(Vector3 * normal)
{
    Plane * plane = npfreenode_alloc(NP_PLANE_FREELIST);
    plane->normal = *normal;
    plane->d      = 0.0;

    v3_v_normalise(&(plane->normal));

    return plane;
}

Plane * plane_alloc_init_with_normal_and_scalar(Vector3 * normal, Double scalar)
{
    Plane * plane = npfreenode_alloc(NP_PLANE_FREELIST);
    plane->normal = *normal;
    plane->d      = scalar;

    v3_v_normalise(&(plane->normal));

    return plane;
}

Plane * plane_free(Plane * p)
{
    return npfreenode_free(p, NP_PLANE_FREELIST);
}

int32_t plane_pr_intersect_with_ray_v(Plane * plane, Ray * ray, Vector3 * result)
{
    Double raypoint_dot_planenormal     = v3_vv_dot_product(&(ray->point),     &(plane->normal));
    Double raydirection_dot_planenormal = v3_vv_dot_product(&(ray->direction), &(plane->normal));

    if ( fabs(raydirection_dot_planenormal) <= MATH_DOUBLE_EPSILON )
    {
        return 0;
    }

    Double t = ( plane->d - raypoint_dot_planenormal ) / raydirection_dot_planenormal;

    v3_sv_scale_v(t, &(ray->direction), result);
    v3_vv_add_v(result, &(ray->point), result);

    return 1;
}

Double plane_pv_distance_from_plane_s(Plane * plane, Vector3 * point)
{
    Double tmp = v3_vv_dot_product(&(plane->normal), point);

    return fabs(tmp + plane->d);
}
