#include <math.h>
#include "Core/Basics/NpFreeList.h"
#include "FTriangle.h"

NpFreeList * NP_FTRIANGLE_FREELIST = NULL;

void npmath_ftriangle_initialise(void)
{
    NPFREELIST_ALLOC_INIT(NP_FTRIANGLE_FREELIST, FTriangle, 512);
}

FTriangle * ftriangle_alloc(void)
{
    return npfreenode_alloc(NP_FTRIANGLE_FREELIST);
}

FTriangle * ftriangle_alloc_init(void)
{
    FTriangle * triangle = npfreenode_alloc(NP_FTRIANGLE_FREELIST);

    triangle->a = fv2_zero();
    triangle->b = fv2_zero();
    triangle->c = fv2_zero();

    return triangle;
}

void ftriangle_free(FTriangle * t)
{
    npfreenode_free(t, NP_FTRIANGLE_FREELIST);
}

void ftriangle_tvvv_init_with_vertices(FTriangle * triangle,
    const FVector2 * const a,
    const FVector2 * const b,
    const FVector2 * const c)
{
    triangle->a = *a;
    triangle->b = *b;
    triangle->c = *c;
}

int32_t ftriangle_vt_is_point_inside(const FVector2 * const point,
    const FTriangle * const triangle)
{
    const FVector2 ab = fv2_vv_sub(&triangle->b, &triangle->a);
    const FVector2 bc = fv2_vv_sub(&triangle->c, &triangle->b);
    const FVector2 ca = fv2_vv_sub(&triangle->a, &triangle->c);

    const FVector2 ap = fv2_vv_sub(point, &triangle->a);
    const FVector2 bp = fv2_vv_sub(point, &triangle->b);
    const FVector2 cp = fv2_vv_sub(point, &triangle->c);

    // ABxAP, BCxBP and CAxCP
    // (x1,y1,0)x(x2,y2,0)=(0,0,x1y2−x2y1)
    const float signOne   = copysignf(1.0f, ab.x * ap.y - ab.y * ap.x);
    const float signTwo   = copysignf(1.0f, bc.x * bp.y - bc.y * bp.x);
    const float signThree = copysignf(1.0f, ca.x * cp.y - ca.y * cp.x);

    return (signOne == signTwo && signOne == signThree) ? 1 : 0;
}
