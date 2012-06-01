#include <math.h>
#include "FPlane.h"
#include "Constants.h"

NpFreeList * NP_FPLANE_FREELIST = NULL;

void npmath_fplane_initialise()
{
    NPFREELIST_ALLOC_INIT(NP_FPLANE_FREELIST, FPlane, 512);
}

FPlane * fplane_alloc()
{
    return npfreenode_alloc(NP_FPLANE_FREELIST);
}

FPlane * fplane_alloc_init()
{
    FPlane * plane  = npfreenode_alloc(NP_FPLANE_FREELIST);
    plane->normal.x = plane->normal.y = plane->normal.z = 0.0f;
    plane->d        = 0.0f;

    return plane;
}

FPlane * fplane_alloc_init_with_normal(const FVector3 * const normal)
{
    FPlane * plane = npfreenode_alloc(NP_FPLANE_FREELIST);
    plane->normal  = *normal;
    plane->d       = 0.0f;

    fv3_v_normalise(&(plane->normal));

    return plane;
}

FPlane * fplane_alloc_init_with_normal_and_scalar(const FVector3 * const normal, const float scalar)
{
    FPlane * plane = npfreenode_alloc(NP_FPLANE_FREELIST);
    plane->normal = *normal;
    plane->d      = scalar;

    fv3_v_normalise(&(plane->normal));

    return plane;
}

FPlane * fplane_alloc_init_with_components(const float x, const float y, const float z, const float scalar)
{
    FPlane * plane = npfreenode_alloc(NP_FPLANE_FREELIST);
    plane->normal.x = x;
    plane->normal.y = y;
    plane->normal.z = z;
    plane->d = scalar;

    fv3_v_normalise(&(plane->normal));

    return plane;
}

FPlane * fplane_free(FPlane * p)
{
    return npfreenode_free(p, NP_FPLANE_FREELIST);
}

void fplane_pv_init_with_normal(FPlane * plane, const FVector3 * const normal)
{
    plane->normal = *normal;
    plane->d      = 0.0f;

    fv3_v_normalise(&(plane->normal));  
}

void fplane_pvs_init_with_normal_and_scalar(FPlane * plane, const FVector3 * const normal, const float scalar)
{
    plane->normal = *normal;
    plane->d      = scalar;

    fv3_v_normalise(&(plane->normal)); 
}

void fplane_pssss_init_with_components(FPlane * plane, const float x, const float y, const float z, const float scalar)
{
    plane->normal.x = x;
    plane->normal.y = y;
    plane->normal.z = z;
    plane->d = scalar;

    fv3_v_normalise(&(plane->normal));
}

int32_t fplane_pr_intersect_with_ray_v(const FPlane * const plane, const FRay * const ray, FVector3 * result)
{
    const float raypoint_dot_planenormal     = fv3_vv_dot_product(&(ray->point),     &(plane->normal));
    const float raydirection_dot_planenormal = fv3_vv_dot_product(&(ray->direction), &(plane->normal));

    if ( fabs(raydirection_dot_planenormal) <= MATH_FLOAT_EPSILON )
    {
        return 0;
    }

    const float t = ( plane->d - raypoint_dot_planenormal ) / raydirection_dot_planenormal;

    fv3_sv_scale_v(t, &(ray->direction), result);
    fv3_vv_add_v(result, &(ray->point), result);

    int32_t r = 1;
    if ( t < 0.0f )
    {
        r = -1;
    }

    return r;
}

float fplane_pv_signed_distance_from_plane_s(const FPlane * const plane, const FVector3 * const point)
{
    const float tmp = fv3_vv_dot_product(&(plane->normal), point);

    return tmp + plane->d;
}

float fplane_pv_distance_from_plane_s(const FPlane * const plane, const FVector3 * const point)
{
    const float tmp = fv3_vv_dot_product(&(plane->normal), point);

    return fabsf(tmp + plane->d);
}
