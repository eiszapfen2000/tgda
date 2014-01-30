#include <float.h>
#include <math.h>
#include "Plane.h"
#include "Constants.h"

NpFreeList * NP_PLANE_FREELIST = NULL;

void npmath_plane_initialise(void)
{
    NPFREELIST_ALLOC_INIT(NP_PLANE_FREELIST, Plane, 512);
}

Plane * plane_alloc(void)
{
    return npfreenode_alloc(NP_PLANE_FREELIST);
}

Plane * plane_alloc_init(void)
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

Plane * plane_alloc_init_with_normal_and_scalar(Vector3 * normal, double scalar)
{
    Plane * plane = npfreenode_alloc(NP_PLANE_FREELIST);
    plane->normal = *normal;
    plane->d      = scalar;

    v3_v_normalise(&(plane->normal));

    return plane;
}

void plane_free(Plane * p)
{
    npfreenode_free(p, NP_PLANE_FREELIST);
}

void plane_pv_init_with_normal(Plane * plane, const Vector3 * const normal)
{
    plane->normal = *normal;
    plane->d      = 0.0;

    v3_v_normalise(&(plane->normal));  
}

void plane_pvs_init_with_normal_and_scalar(Plane * plane, const Vector3 * const normal, const double scalar)
{
    plane->normal = *normal;
    plane->d      = scalar;

    v3_v_normalise(&(plane->normal)); 
}

void plane_pssss_init_with_components(Plane * plane, const double x, const double y, const double z, const double scalar)
{
    plane->normal.x = x;
    plane->normal.y = y;
    plane->normal.z = z;
    plane->d = scalar;

    v3_v_normalise(&(plane->normal));
}

int32_t plane_pr_intersect_with_ray_v(Plane * plane, Ray * ray, Vector3 * result)
{
    const double raypoint_dot_planenormal     = v3_vv_dot_product(&(ray->point),     &(plane->normal));
    const double raydirection_dot_planenormal = v3_vv_dot_product(&(ray->direction), &(plane->normal));

    if ( fabs(raydirection_dot_planenormal) <= DBL_EPSILON )
    {
        return 0;
    }

    const double t = ( plane->d - raypoint_dot_planenormal ) / raydirection_dot_planenormal;

    v3_sv_scale_v(t, &(ray->direction), result);
    v3_vv_add_v(result, &(ray->point), result);

    int32_t r = 1;
    if ( t < 0.0 )
    {
        r = -1;
    }

    return r;
}

double plane_pv_signed_distance_from_plane(const Plane * const plane, const Vector3 * const point)
{
    const double tmp = v3_vv_dot_product(&(plane->normal), point);

    return tmp - plane->d;
}

double plane_pv_distance_from_plane(Plane * plane, Vector3 * point)
{
    double tmp = v3_vv_dot_product(&(plane->normal), point);

    return fabs(tmp - plane->d);
}
