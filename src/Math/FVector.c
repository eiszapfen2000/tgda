#include "FVector.h"

#include <math.h>

Float fv2_v_square_length(const FVector2 * const v)
{
    return (v->x * v->x + v->y * v->y);
}

Float fv2_v_length(const FVector2 * const v)
{
    return sqrt(fv2_v_square_length(v));
}

void fv2_v_normalize_v(const FVector2 * const v, FVector2 * n)
{
    Float length = fv2_v_length(v);
    n->x = v->x/length;
    n->y = v->y/length;
}

void fv2_v_normalize(FVector2 * v)
{
    Float length = fv2_v_length(v);
    v->x = v->x/length;
    v->y = v->y/length;
}

Float fv2_vv_dot_product(const FVector2 * const v, const FVector2 * const w)
{
    return (v->x * w->x + v->y * w->y);
}

Float fv3_v_square_length(const FVector3 * const v)
{
    return (v->x * v->x + v->y * v->y + v->z * v->z);
}

Float fv3_v_length(const FVector3 * const v)
{
    return sqrt(fv3_v_square_length(v));
}

void fv3_v_normalize_v(const FVector3 * const v, FVector3 * n)
{
    Float length = fv3_v_length(v);
    n->x = v->x/length;
    n->y = v->y/length;
    n->z = v->z/length;
}

void fv3_v_normalize(FVector3 * v)
{
    Float length = fv3_v_length(v);
    v->x = v->x/length;
    v->y = v->y/length;
    v->z = v->z/length;
}

Float fv3_vv_dot_product(const FVector3 * const v, const FVector3 * const w)
{
    return (v->x * w->x + v->y * w->y + v->z * w->z);
}

void fv3_vv_cross_product_v(const FVector3 * const v, const FVector3 * const w, FVector3 * out)
{
    out->x = v->y * w->z - v->z * w->y;
    out->y = v->z * w->x - v->x * w->z;
    out->z = v->x * w->y - v->y * w->x;
}
