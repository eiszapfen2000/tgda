#include "Basics/Memory.h"
#include "Vector.h"

#include <math.h>

NpFreeList * NP_VECTOR2_FREELIST = NULL;
NpFreeList * NP_VECTOR3_FREELIST = NULL;
NpFreeList * NP_VECTOR4_FREELIST = NULL;

void npmath_vector_initialise()
{
    NPFREELIST_ALLOC_INIT(NP_VECTOR2_FREELIST,Vector2,512)
    NPFREELIST_ALLOC_INIT(NP_VECTOR3_FREELIST,Vector3,512)
    NPFREELIST_ALLOC_INIT(NP_VECTOR4_FREELIST,Vector4,512)
}

void v2_v_square_length_s(const Vector2 * const v, Double * sqrlength)
{
    *sqrlength = V_X(*v) * V_X(*v) + V_Y(*v) * V_Y(*v);
}

void v2_v_length_s(const Vector2 * const v, Double * length)
{
    *length = sqrt(V_X(*v) * V_X(*v) + V_Y(*v) * V_Y(*v));
}

void v2_v_normalise_v(const Vector2 * const v, Vector2 * normalised)
{
    Double length = v2_v_length(v);
    V_X(*normalised) = V_X(*v)/length;
    V_Y(*normalised) = V_Y(*v)/length;
}

void v2_v_normalise(Vector2 * v)
{
    Double length = v2_v_length(v);
    V_X(*v) = V_X(*v)/length;
    V_Y(*v) = V_Y(*v)/length;
}

void v2_sv_scale(Vector2 * v, const Double * const scale)
{
    V_X(*v) *= *scale;
    V_Y(*v) *= *scale;
}

void v2_sv_scalex(Vector2 * v, const Double * const scale)
{
    V_X(*v) *= *scale;
}

void v2_sv_scaley(Vector2 * v, const Double * const scale)
{
    V_Y(*v) *= *scale;
}

void v2_sv_scale_v(const Vector2 * const v, const Double * const scale, Vector2 * result)
{
    V_X(*result) = V_X(*v) * *scale;
    V_Y(*result) = V_Y(*v) * *scale;
}

void v2_sv_scalex_v(const Vector2 * const v, const Double * const scale, Vector2 * result)
{
    V_X(*result) = V_X(*v) * *scale;
}

void v2_sv_scaley_v(const Vector2 * const v, const Double * const scale, Vector2 * result)
{
    V_Y(*result) = V_Y(*v) * *scale;
}

void v2_vv_add_v(const Vector2 * const v, const Vector2 * const w, Vector2 * result)
{
    V_X(*result) = V_X(*v) + V_X(*w);
    V_Y(*result) = V_Y(*v) + V_Y(*w);
}

void v2_vv_sub_v(const Vector2 * const v, const Vector2 * const w, Vector2 * result)
{
    V_X(*result) = V_X(*v) - V_X(*w);
    V_Y(*result) = V_Y(*v) - V_Y(*w);
}

void v2_vv_dot_product_s(const Vector2 * const v, const Vector2 * const w, Double * dot)
{
    *dot = V_X(*v) * V_X(*w) + V_Y(*v) * V_Y(*w);
}

Double v2_vv_dot_product(const Vector2 * const v, const Vector2 * const w)
{
    return ( V_X(*v) * V_X(*w) + V_Y(*v) * V_Y(*w) );
}

Double v2_v_square_length(const Vector2 * const v)
{
    return ( V_X(*v) * V_X(*v) + V_Y(*v) * V_Y(*v) );
}

Double v2_v_length(const Vector2 * const v)
{
    return sqrt(v2_v_square_length(v));
}

Vector2 * v2_alloc()
{
    return (Vector2 *)npfreenode_alloc(NP_VECTOR2_FREELIST);
}

Vector2 * v2_alloc_init()
{
    Vector2 * tmp = npfreenode_alloc(NP_VECTOR2_FREELIST);
    V_X(*tmp) = V_Y(*tmp) = 0.0;

    return tmp;
}

void v3_v_square_length_s(const Vector3 * const v, Double * sqrlength)
{
    *sqrlength = V_X(*v) * V_X(*v) + V_Y(*v) * V_Y(*v) + V_Z(*v) * V_Z(*v);
}

void v3_v_length_s(const Vector3 * const v, Double * length)
{
    *length = sqrt(V_X(*v) * V_X(*v) + V_Y(*v) * V_Y(*v) + V_Z(*v) * V_Z(*v));
}

void v3_v_normalise_v(const Vector3 * const v, Vector3 * normalised)
{
    Double length = v3_v_length(v);
    V_X(*normalised) = V_X(*v)/length;
    V_Y(*normalised) = V_Y(*v)/length;
    V_Z(*normalised) = V_Z(*v)/length;
}

void v3_v_normalise(Vector3 * v)
{
    Double length = v3_v_length(v);
    V_X(*v) = V_X(*v)/length;
    V_Y(*v) = V_Y(*v)/length;
    V_Z(*v) = V_Z(*v)/length;
}

void v3_sv_scale(Vector3 * v, const Double * const scale)
{
    V_X(*v) *= *scale;
    V_Y(*v) *= *scale;
    V_Z(*v) *= *scale;
}

void v3_sv_scalex(Vector3 * v, const Double * const scale)
{
    V_X(*v) *= *scale;
}

void v3_sv_scaley(Vector3 * v, const Double * const scale)
{
    V_Y(*v) *= *scale;
}

void v3_sv_scalez(Vector3 * v, const Double * const scale)
{
    V_Z(*v) *= *scale;
}

void v3_sv_scale_v(const Vector3 * const v, const Double * const scale, Vector3 * result)
{
    V_X(*result) = V_X(*v) * *scale;
    V_Y(*result) = V_Y(*v) * *scale;
    V_Z(*result) = V_Z(*v) * *scale;
}

void v3_sv_scalex_v(const Vector3 * const v, const Double * const scale, Vector3 * result)
{
    V_X(*result) = V_X(*v) * *scale;
}

void v3_sv_scaley_v(const Vector3 * const v, const Double * const scale, Vector3 * result)
{
    V_Y(*result) = V_Y(*v) * *scale;
}

void v3_sv_scalez_v(const Vector3 * const v, const Double * const scale, Vector3 * result)
{
    V_Z(*result) = V_Z(*v) * *scale;
}

void v3_vv_add_v(const Vector3 * const v, const Vector3 * const w, Vector3 * result)
{
    V_X(*result) = V_X(*v) + V_X(*w);
    V_Y(*result) = V_Y(*v) + V_Y(*w);
    V_Z(*result) = V_Z(*v) + V_Z(*w);
}

void v3_vv_sub_v(const Vector3 * const v, const Vector3 * const w, Vector3 * result)
{
    V_X(*result) = V_X(*v) - V_X(*w);
    V_Y(*result) = V_Y(*v) - V_Y(*w);
    V_Z(*result) = V_Z(*v) - V_Z(*w);
}

void v3_vv_dot_product_s(const Vector3 * const v, const Vector3 * const w, Double * dot)
{
    *dot = V_X(*v) * V_X(*w) + V_Y(*v) * V_Y(*w) + V_Z(*v) * V_Z(*w);
}

void v3_vv_cross_product_v(const Vector3 * const v, const Vector3 * const w, Vector3 * cross)
{
    V_X(*cross) = V_Y(*v) * V_Z(*w) - V_Z(*v) * V_Y(*w);
    V_Y(*cross) = V_Z(*v) * V_X(*w) - V_X(*v) * V_Z(*w);
    V_Z(*cross) = V_X(*v) * V_Y(*w) - V_Y(*v) * V_X(*w);
}

Double v3_v_square_length(const Vector3 * const v)
{
    return ( V_X(*v) * V_X(*v) + V_Y(*v) * V_Y(*v) + V_Z(*v) * V_Z(*v) );
}

Double v3_v_length(const Vector3 * const v)
{
    return sqrt(v3_v_square_length(v));
}

Double v3_vv_dot_product(const Vector3 * const v, const Vector3 * const w)
{
    return ( V_X(*v) * V_X(*w) + V_Y(*v) * V_Y(*w) + V_Z(*v) * V_Z(*w) );
}

Vector3 * v3_alloc()
{
    return (Vector3 *)npfreenode_alloc(NP_VECTOR3_FREELIST);
}

Vector3 * v3_alloc_init()
{
    Vector3 * tmp = npfreenode_alloc(NP_VECTOR3_FREELIST);
    V_X(*tmp) = V_Y(*tmp) = V_Z(*tmp) = 0.0;

    return tmp;
}

Vector4 * v4_alloc()
{
    return (Vector4 *)npfreenode_alloc(NP_VECTOR4_FREELIST);
}

Vector4 * v4_alloc_init()
{
    Vector4 * tmp = npfreenode_alloc(NP_VECTOR4_FREELIST);
    V_X(*tmp) = V_Y(*tmp) = V_Z(*tmp) = 0.0;
    V_W(*tmp) = 1.0;

    return tmp;
}

