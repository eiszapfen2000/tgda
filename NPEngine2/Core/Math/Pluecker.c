#define _GNU_SOURCE
#include <stdio.h>
#include <math.h>

#include "Pluecker.h"
#include "Utilities.h"

NpFreeList * NP_PLUECKER_FREELIST = NULL;

void npmath_pluecker_initialise(void)
{
    NPFREELIST_ALLOC_INIT(NP_PLUECKER_FREELIST, Pluecker, 64)
}

Pluecker * pluecker_alloc(void)
{
    return (Pluecker *)npfreenode_alloc(NP_PLUECKER_FREELIST);
}

Pluecker * pluecker_alloc_init(void)
{
    Pluecker * tmp = npfreenode_alloc(NP_PLUECKER_FREELIST);

    v3_vsss_init_with_components(&(tmp->U), 1.0, 0.0, 0.0);
    v3_vsss_init_with_components(&(tmp->V), 0.0, 1.0, 0.0);

    return tmp;
}

Pluecker * pluecker_alloc_init_with_points(const Vector3 const * p1, const Vector3 const * p2)
{
    Pluecker * tmp = npfreenode_alloc(NP_PLUECKER_FREELIST);

    v3_vv_sub_v(p2, p1, &(tmp->U));
    v3_vv_cross_product_v(p2, p1, &(tmp->V));

    return tmp;
}

Pluecker * pluecker_alloc_init_with_point_and_direction(const Vector3 const * point, const Vector3 const * direction)
{
    Pluecker * tmp = npfreenode_alloc(NP_PLUECKER_FREELIST);

    v3_vv_init_with_v3(&(tmp->U), direction);
    v3_vv_cross_product_v(direction, point, &(tmp->V));

    return tmp;
}

void pluecker_free(Pluecker * p)
{
    npfreenode_free(p, NP_PLUECKER_FREELIST);
}

void pluecker_init_with_points(Pluecker * pl, const Vector3 const * p1, const Vector3 const * p2)
{
    v3_vv_sub_v(p2, p1, &(pl->U));
    v3_vv_cross_product_v(p2, p1, &(pl->V));
}

void pluecker_init_with_point_and_direction(Pluecker * pl, const Vector3 const * point, const Vector3 const * direction)
{
    v3_vv_init_with_v3(&(pl->U), direction);
    v3_vv_cross_product_v(direction, point, &(pl->V));
}

int32_t pluecker_plp_intersect_with_plane_v(const Pluecker const * pluecker, const Plane const * p, Vector3 * result)
{
    Double dot = v3_vv_dot_product(&(pluecker->U), &(p->normal));

    Vector3 cross = v3_vv_cross_product(&(pluecker->V), &(p->normal));
    Vector3 scaled = v3_sv_scaled(p->d, &(pluecker->U));
    Vector3 sub = v3_vv_sub(&cross, &scaled);
    v3_sv_scale_v(dot, &sub, result);

    return 1;
}
