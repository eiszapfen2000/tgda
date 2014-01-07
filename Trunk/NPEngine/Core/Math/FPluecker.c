#define _GNU_SOURCE
#include <stdio.h>
#include <math.h>

#include "FPluecker.h"
#include "Utilities.h"

NpFreeList * NP_FPLUECKER_FREELIST = NULL;

void npmath_fpluecker_initialise()
{
    NPFREELIST_ALLOC_INIT(NP_FPLUECKER_FREELIST, FPluecker, 64)
}

FPluecker * fpluecker_alloc()
{
    return (FPluecker *)npfreenode_alloc(NP_FPLUECKER_FREELIST);
}

FPluecker * fpluecker_alloc_init()
{
    FPluecker * tmp = npfreenode_alloc(NP_FPLUECKER_FREELIST);

    fv3_vsss_init_with_components(&(tmp->U), 0.0f, 0.0f, 0.0f);
    fv3_vsss_init_with_components(&(tmp->V), 0.0f, 0.0f, 0.0f);

    return tmp;
}

FPluecker * fpluecker_alloc_init_with_points(const FVector3 const * p1, const FVector3 const * p2)
{
    FPluecker * tmp = npfreenode_alloc(NP_FPLUECKER_FREELIST);

    fv3_vv_sub_v(p2, p1, &(tmp->U));
    fv3_vv_cross_product_v(p2, p1, &(tmp->V));

    return tmp;
}

FPluecker * fpluecker_alloc_init_with_point_and_direction(const FVector3 const * point, const FVector3 const * direction)
{
    FPluecker * tmp = npfreenode_alloc(NP_FPLUECKER_FREELIST);

    fv3_vv_init_with_fv3(&(tmp->U), direction);
    fv3_vv_cross_product_v(direction, point, &(tmp->V));

    return tmp;
}

FPluecker * fpluecker_free(FPluecker * p)
{
    return npfreenode_free(p, NP_FPLUECKER_FREELIST);
}

void fpluecker_init_with_points(FPluecker * pl, const FVector3 const * p1, const FVector3 const * p2)
{
    fv3_vv_sub_v(p2, p1, &(pl->U));
    fv3_vv_cross_product_v(p2, p1, &(pl->V));
}

void fpluecker_init_with_point_and_direction(FPluecker * pl, const FVector3 const * point, const FVector3 const * direction)
{
    fv3_vv_init_with_fv3(&(pl->U), direction);
    fv3_vv_cross_product_v(direction, point, &(pl->V));
}

Int fpluecker_plp_intersect_with_plane_v(const FPluecker const * fpluecker, const FPlane const * p, FVector3 * result)
{
    Float dot = fv3_vv_dot_product(&(fpluecker->U), &(p->normal));

    FVector3 cross = fv3_vv_cross_product(&(fpluecker->V), &(p->normal));
    FVector3 scaled = fv3_sv_scaled(p->d, &(fpluecker->U));
    FVector3 sub = fv3_vv_sub(&cross, &scaled);
    fv3_sv_scale_v(dot, &sub, result);

    return 1;
}
