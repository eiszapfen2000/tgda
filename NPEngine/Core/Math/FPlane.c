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
    FPlane * plane   = npfreenode_alloc(NP_FPLANE_FREELIST);
    plane->normal.x = plane->normal.y = plane->normal.z = 0.0f;
    plane->d        = 0.0f;

    return plane;
}

FPlane * fplane_alloc_init_with_normal(FVector3 * normal)
{
    FPlane * plane = npfreenode_alloc(NP_FPLANE_FREELIST);
    plane->normal = *normal;
    plane->d      = 0.0f;

    fv3_v_normalise(&(plane->normal));

    return plane;
}

FPlane * fplane_alloc_init_with_normal_and_scalar(FVector3 * normal, Float scalar)
{
    FPlane * plane = npfreenode_alloc(NP_FPLANE_FREELIST);
    plane->normal = *normal;
    plane->d      = scalar;

    fv3_v_normalise(&(plane->normal));

    return plane;
}

FPlane * fplane_alloc_init_with_components(Float x, Float y, Float z, Float scalar)
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

Int fplane_pr_intersect_with_ray_v(FPlane * plane, FRay * ray, FVector3 * result)
{
    Float raypoint_dot_planenormal     = fv3_vv_dot_product(&(ray->point),     &(plane->normal));
    Float raydirection_dot_planenormal = fv3_vv_dot_product(&(ray->direction), &(plane->normal));

    if ( fabs(raydirection_dot_planenormal) <= MATH_FLOAT_EPSILON )
    {
        return 0;
    }

    Float t = ( plane->d - raypoint_dot_planenormal ) / raydirection_dot_planenormal;

    fv3_sv_scale_v(&t, &(ray->direction), result);
    fv3_vv_add_v(result, &(ray->point), result);

    return 1;
}

Float fplane_pv_distance_from_plane_s(FPlane * plane, FVector3 * point)
{
    Float tmp = fv3_vv_dot_product(&(plane->normal), point);

    return (Float)fabs(tmp + plane->d);
}
