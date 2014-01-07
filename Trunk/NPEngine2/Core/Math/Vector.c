#define _GNU_SOURCE
#include <stdio.h>
#include <math.h>

#include "Core/Basics/NpFreeList.h"
#include "Vector.h"

NpFreeList * NP_VECTOR2_FREELIST = NULL;
NpFreeList * NP_VECTOR3_FREELIST = NULL;
NpFreeList * NP_VECTOR4_FREELIST = NULL;

Vector3 * NP_WORLD_X_AXIS = NULL;
Vector3 * NP_WORLD_Y_AXIS = NULL;
Vector3 * NP_WORLD_Z_AXIS = NULL;
Vector3 * NP_WORLD_FORWARD_VECTOR = NULL;

void npmath_vector_initialise(void)
{
    NPFREELIST_ALLOC_INIT(NP_VECTOR2_FREELIST, Vector2, 512)
    NPFREELIST_ALLOC_INIT(NP_VECTOR3_FREELIST, Vector3, 512)
    NPFREELIST_ALLOC_INIT(NP_VECTOR4_FREELIST, Vector4, 512)

    NP_WORLD_X_AXIS = v3_alloc_init(); V_X(*NP_WORLD_X_AXIS) = 1.0;
    NP_WORLD_Y_AXIS = v3_alloc_init(); V_Y(*NP_WORLD_Y_AXIS) = 1.0;
    NP_WORLD_Z_AXIS = v3_alloc_init(); V_Z(*NP_WORLD_Z_AXIS) = 1.0;
    NP_WORLD_FORWARD_VECTOR = v3_alloc_init(); V_Z(*NP_WORLD_FORWARD_VECTOR) = -1.0;
}

Vector2 * v2_alloc(void)
{
    return (Vector2 *)npfreenode_alloc(NP_VECTOR2_FREELIST);
}

Vector2 * v2_alloc_init(void)
{
    Vector2 * tmp = npfreenode_alloc(NP_VECTOR2_FREELIST);
    V_X(*tmp) = V_Y(*tmp) = 0.0;

    return tmp;
}

Vector2 * v2_alloc_init_with_components(double x, double y)
{
    Vector2 * tmp = npfreenode_alloc(NP_VECTOR2_FREELIST);
    V_X(*tmp) = x;
    V_Y(*tmp) = y;

    return tmp;
}

void v2_free(Vector2 * v)
{
    npfreenode_free(v, NP_VECTOR2_FREELIST);
}

void v2_v_init_with_zeros(Vector2 * v)
{
    V_X(*v) = V_Y(*v) = 0.0;
}

void v2_vss_init_with_components(Vector2 * v, double x, double y)
{
    V_X(*v) = x;
    V_Y(*v) = y;
}

void v2_v_invert(Vector2 * v)
{
    V_X(*v) = -V_X(*v);
    V_Y(*v) = -V_Y(*v);
}

void v2_v_invert_v(const Vector2 * const v, Vector2 * result)
{
    V_X(*result) = -V_X(*v);
    V_Y(*result) = -V_Y(*v);
}

void v2_v_normalise_v(const Vector2 * const v, Vector2 * normalised)
{
    double length = v2_v_length(v);
    V_X(*normalised) = V_X(*v)/length;
    V_Y(*normalised) = V_Y(*v)/length;
}

void v2_v_normalise(Vector2 * v)
{
    double length = v2_v_length(v);
    V_X(*v) = V_X(*v)/length;
    V_Y(*v) = V_Y(*v)/length;
}

void v2_sv_scale(double scale, Vector2 * v)
{
    V_X(*v) *= scale;
    V_Y(*v) *= scale;
}

void v2_sv_scalex(double scale, Vector2 * v)
{
    V_X(*v) *= scale;
}

void v2_sv_scaley(double scale, Vector2 * v)
{
    V_Y(*v) *= scale;
}

void v2_sv_scale_v(double scale, const Vector2 * const v, Vector2 * result)
{
    V_X(*result) = V_X(*v) * scale;
    V_Y(*result) = V_Y(*v) * scale;
}

void v2_sv_scalex_v(double scale, const Vector2 * const v, Vector2 * result)
{
    V_X(*result) = V_X(*v) * scale;
}

void v2_sv_scaley_v(double scale, const Vector2 * const v, Vector2 * result)
{
    V_Y(*result) = V_Y(*v) * scale;
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

double v2_vv_dot_product(const Vector2 * const v, const Vector2 * const w)
{
    return ( V_X(*v) * V_X(*w) + V_Y(*v) * V_Y(*w) );
}

double v2_v_square_length(const Vector2 * const v)
{
    return ( V_X(*v) * V_X(*v) + V_Y(*v) * V_Y(*v) );
}

double v2_v_length(const Vector2 * const v)
{
    return sqrt(v2_v_square_length(v));
}

Vector2 v2_zero(void)
{
    return (Vector2){0.0, 0.0};
}

Vector2 v2_min(void)
{
    return (Vector2){-DBL_MAX, -DBL_MAX};
}

Vector2 v2_max(void)
{
    return (Vector2){DBL_MAX, DBL_MAX};
}

Vector2 v2_v_inverted(Vector2 * v)
{
    return (Vector2){-V_X(*v), -V_Y(*v)};
}

Vector2 v2_v_normalised(const Vector2 * const v)
{
    double length = v2_v_length(v);
    return (Vector2){ V_X(*v) / length, V_Y(*v) / length };
}

Vector2 v2_vv_add(const Vector2 * const v, const Vector2 * const w)
{
    return (Vector2){V_X(*v) + V_X(*w), V_Y(*v) + V_Y(*w)};
}

Vector2 v2_vv_sub(const Vector2 * const v, const Vector2 * const w)
{
    return (Vector2){V_X(*v) - V_X(*w), V_Y(*v) - V_Y(*w)};
}

Vector2 v2_sv_scaled(double scale, const Vector2 * const v)
{
    return (Vector2){V_X(*v) * scale, V_Y(*v) * scale};
}

Vector2 v2_sv_scaledx(double scale, const Vector2 * const v)
{
    return (Vector2){V_X(*v) * scale, V_Y(*v)};
}

Vector2 v2_sv_scaledy(double scale, const Vector2 * const v)
{
    return (Vector2){V_X(*v) * scale, V_Y(*v)};
}

const char * v2_v_to_string(Vector2 * v)
{
    char * v2string;

    if ( asprintf(&v2string, "(%f, %f)", V_X(*v), V_Y(*v)) < 0)
    {
        return NULL;
    }

    return v2string;
}

// ----------------------------------------------------------------------------

Vector3 * v3_alloc(void)
{
    return (Vector3 *)npfreenode_alloc(NP_VECTOR3_FREELIST);
}

Vector3 * v3_alloc_init(void)
{
    Vector3 * tmp = npfreenode_alloc(NP_VECTOR3_FREELIST);
    V_X(*tmp) = V_Y(*tmp) = V_Z(*tmp) = 0.0;

    return tmp;
}

Vector3 * v3_alloc_init_with_components(double x, double y, double z)
{
    Vector3 * tmp = npfreenode_alloc(NP_VECTOR3_FREELIST);
    V_X(*tmp) = x;
    V_Y(*tmp) = y;
    V_Z(*tmp) = z;

    return tmp;
}

void v3_free(Vector3 * v)
{
    npfreenode_free(v, NP_VECTOR3_FREELIST);
}

void v3_v_init_with_zeros(Vector3 * v)
{
    V_X(*v) = V_Y(*v) = V_Z(*v) = 0.0;
}

void v3_vsss_init_with_components(Vector3 * v, double x, double y, double z)
{
    V_X(*v) = x;
    V_Y(*v) = y;
    V_Z(*v) = z;
}

void v3_v_invert(Vector3 * v)
{
    V_X(*v) = -V_X(*v);
    V_Y(*v) = -V_Y(*v);
    V_Z(*v) = -V_Z(*v);
}

void v3_v_invert_v(const Vector3 * const v, Vector3 * result)
{
    V_X(*result) = -V_X(*v);
    V_Y(*result) = -V_Y(*v);
    V_Z(*result) = -V_Z(*v);
}

void v3_v_normalise_v(const Vector3 * const v, Vector3 * normalised)
{
    double length = v3_v_length(v);
    V_X(*normalised) = V_X(*v)/length;
    V_Y(*normalised) = V_Y(*v)/length;
    V_Z(*normalised) = V_Z(*v)/length;
}

void v3_v_normalise(Vector3 * v)
{
    double length = v3_v_length(v);
    V_X(*v) = V_X(*v)/length;
    V_Y(*v) = V_Y(*v)/length;
    V_Z(*v) = V_Z(*v)/length;
}

void v3_sv_scale(double scale, Vector3 * v)
{
    V_X(*v) *= scale;
    V_Y(*v) *= scale;
    V_Z(*v) *= scale;
}

void v3_sv_scalex(double scale, Vector3 * v)
{
    V_X(*v) *= scale;
}

void v3_sv_scaley(double scale, Vector3 * v)
{
    V_Y(*v) *= scale;
}

void v3_sv_scalez(double scale, Vector3 * v)
{
    V_Z(*v) *= scale;
}

void v3_sv_scale_v(double scale, const Vector3 * const v, Vector3 * result)
{
    V_X(*result) = V_X(*v) * scale;
    V_Y(*result) = V_Y(*v) * scale;
    V_Z(*result) = V_Z(*v) * scale;
}

void v3_sv_scalex_v(double scale, const Vector3 * const v, Vector3 * result)
{
    V_X(*result) = V_X(*v) * scale;
}

void v3_sv_scaley_v(double scale, const Vector3 * const v, Vector3 * result)
{
    V_Y(*result) = V_Y(*v) * scale;
}

void v3_sv_scalez_v(double scale, const Vector3 * const v, Vector3 * result)
{
    V_Z(*result) = V_Z(*v) * scale;
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

void v3_vv_cross_product_v(const Vector3 * const v, const Vector3 * const w, Vector3 * cross)
{
    V_X(*cross) = V_Y(*v) * V_Z(*w) - V_Z(*v) * V_Y(*w);
    V_Y(*cross) = V_Z(*v) * V_X(*w) - V_X(*v) * V_Z(*w);
    V_Z(*cross) = V_X(*v) * V_Y(*w) - V_Y(*v) * V_X(*w);
}

double v3_vv_dot_product(const Vector3 * const v, const Vector3 * const w)
{
    return ( V_X(*v) * V_X(*w) + V_Y(*v) * V_Y(*w) + V_Z(*v) * V_Z(*w) );
}

double v3_v_square_length(const Vector3 * const v)
{
    return ( V_X(*v) * V_X(*v) + V_Y(*v) * V_Y(*v) + V_Z(*v) * V_Z(*v) );
}

double v3_v_length(const Vector3 * const v)
{
    return sqrt(v3_v_square_length(v));
}

Vector3 v3_zero(void)
{
    return (Vector3){0.0, 0.0, 0.0};
}

Vector3 v3_min(void)
{
    return (Vector3){-DBL_MAX, -DBL_MAX, -DBL_MAX};
}

Vector3 v3_max(void)
{
    return (Vector3){DBL_MAX, DBL_MAX, DBL_MAX};
}

Vector3 v3_v_inverted(Vector3 * v)
{
    return (Vector3){-V_X(*v), -V_Y(*v), -V_Z(*v)};
}

Vector3 v3_v_normalised(const Vector3 * const v)
{
    double length = v3_v_length(v);

    return (Vector3){ V_X(*v) / length, V_Y(*v) / length, V_Z(*v) / length };
}

Vector3 v3_vv_add(const Vector3 * const v, const Vector3 * const w)
{
    return (Vector3){V_X(*v) + V_X(*w), V_Y(*v) + V_Y(*w), V_Z(*v) + V_Z(*w)};
}

Vector3 v3_vv_sub(const Vector3 * const v, const Vector3 * const w)
{
    return (Vector3){V_X(*v) - V_X(*w), V_Y(*v) - V_Y(*w), V_Z(*v) - V_Z(*w)};
}

Vector3 v3_vv_cross_product(const Vector3 * const v, const Vector3 * const w)
{
    return (Vector3){V_Y(*v) * V_Z(*w) - V_Z(*v) * V_Y(*w),
                     V_Z(*v) * V_X(*w) - V_X(*v) * V_Z(*w),
                     V_X(*v) * V_Y(*w) - V_Y(*v) * V_X(*w)};
}

Vector3 v3_sv_scaled(double scale, const Vector3 * const v)
{
    return (Vector3){V_X(*v) * scale, V_Y(*v) * scale, V_Z(*v) * scale};
}

Vector3 v3_sv_scaledx(double scale, const Vector3 * const v)
{
    return (Vector3){V_X(*v) * scale, V_Y(*v), V_Z(*v)};
}

Vector3 v3_sv_scaledy(double scale, const Vector3 * const v)
{
    return (Vector3){V_X(*v), V_Y(*v) * scale, V_Z(*v)};
}

Vector3 v3_sv_scaledz(double scale, const Vector3 * const v)
{
    return (Vector3){V_X(*v), V_Y(*v), V_Z(*v) * scale};
}

const char * v3_v_to_string(Vector3 * v)
{
    char * v3string;

    if ( asprintf(&v3string, "(%f, %f, %f)", V_X(*v), V_Y(*v), V_Z(*v)) < 0)
    {
        return NULL;
    }

    return v3string;
}

//-----------------------------------------------------------------------------

Vector4 * v4_alloc(void)
{
    return (Vector4 *)npfreenode_alloc(NP_VECTOR4_FREELIST);
}

Vector4 * v4_alloc_init(void)
{
    Vector4 * tmp = npfreenode_alloc(NP_VECTOR4_FREELIST);
    V_X(*tmp) = V_Y(*tmp) = V_Z(*tmp) = 0.0;
    V_W(*tmp) = 1.0;

    return tmp;
}

Vector4 * v4_alloc_init_with_v3(const Vector3 * const v)
{
    Vector4 * tmp = npfreenode_alloc(NP_VECTOR4_FREELIST);
    V_X(*tmp) = V_X(*v);
    V_Y(*tmp) = V_Y(*v);
    V_Z(*tmp) = V_Z(*v);
    V_W(*tmp) = 1.0;

    return tmp;
}

Vector4 * v4_alloc_init_with_components(double x, double y, double z, double w)
{
    Vector4 * tmp = npfreenode_alloc(NP_VECTOR4_FREELIST);
    V_X(*tmp) = x;
    V_Y(*tmp) = y;
    V_Z(*tmp) = z;
    V_W(*tmp) = w;

    return tmp;
}

void v4_free(Vector4 * v)
{
    npfreenode_free(v, NP_VECTOR4_FREELIST);
}

void v4_v_init_with_zeros(Vector4 * v)
{
    V_X(*v) = V_Y(*v) = V_Z(*v) = V_W(*v) = 0.0;
}

void v4_vv_init_with_v3(Vector4 * v1, const Vector3 * const v2)
{
    V_X(*v1) = V_X(*v2);
    V_Y(*v1) = V_Y(*v2);
    V_Z(*v1) = V_Z(*v2);
    V_W(*v1) = 1.0;
}

void v4_vssss_init_with_components(Vector4 * v, double x, double y, double z, double w)
{
    V_X(*v) = x;
    V_Y(*v) = y;
    V_Z(*v) = z;
    V_W(*v) = w;
}

void v4_v_homogenise(Vector4 * v)
{
    V_X(*v) = V_X(*v) / V_W(*v);
    V_Y(*v) = V_Y(*v) / V_W(*v);
    V_Z(*v) = V_Z(*v) / V_W(*v);
    V_W(*v) = 1.0;
}

void v4_v_homogenise_v(const Vector4 * const v, Vector4 * result)
{
    V_X(*result) = V_X(*v) / V_W(*v);
    V_Y(*result) = V_Y(*v) / V_W(*v);
    V_Z(*result) = V_Z(*v) / V_W(*v);
    V_W(*result) = 1.0;
}

void v4_sv_scale(double scale, Vector4 * v)
{
    V_X(*v) = V_X(*v) * scale;
    V_Y(*v) = V_Y(*v) * scale;
    V_Z(*v) = V_Z(*v) * scale;
    V_W(*v) = V_W(*v) * scale;
}

void v4_sv_scale_v(double scale, const Vector4 * const v, Vector4 * result)
{
    V_X(*result) = V_X(*v) * scale;
    V_Y(*result) = V_Y(*v) * scale;
    V_Z(*result) = V_Z(*v) * scale;
    V_W(*result) = V_W(*v) * scale;
}

Vector4 v4_v_homogenised(const Vector4 * const v)
{
    return (Vector4){ V_X(*v) / V_W(*v), V_Y(*v) / V_W(*v),
                       V_Z(*v) / V_W(*v), 1.0 };
}

Vector4 v4_vv_add(const Vector4 * const v, const Vector4 * const w)
{
    return (Vector4){V_X(*v) + V_X(*w), V_Y(*v) + V_Y(*w),
                     V_Z(*v) + V_Z(*w), V_W(*v) + V_W(*w)};
}

Vector4 v4_vv_sub(const Vector4 * const v, const Vector4 * const w)
{
    return (Vector4){V_X(*v) - V_X(*w), V_Y(*v) - V_Y(*w),
                     V_Z(*v) - V_Z(*w), V_W(*v) - V_W(*w)};
}

const char * v4_v_to_string(Vector4 * v)
{
    char * v4string;

    if ( asprintf(&v4string, "(%f, %f, %f, %f)",V_X(*v),V_Y(*v),V_Z(*v),V_W(*v)) < 0)
    {
        return NULL;
    }

    return v4string;
}


