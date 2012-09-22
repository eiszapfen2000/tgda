#define _GNU_SOURCE
#include <stdio.h>
#include <math.h>

#include "Core/Basics/NpFreeList.h"
#include "FVector.h"

NpFreeList * NP_FVECTOR2_FREELIST = NULL;
NpFreeList * NP_FVECTOR3_FREELIST = NULL;
NpFreeList * NP_FVECTOR4_FREELIST = NULL;

FVector3 * NP_WORLDF_X_AXIS = NULL;
FVector3 * NP_WORLDF_Y_AXIS = NULL;
FVector3 * NP_WORLDF_Z_AXIS = NULL;
FVector3 * NP_WORLDF_FORWARD_VECTOR = NULL;

void npmath_fvector_initialise()
{
    NPFREELIST_ALLOC_INIT(NP_FVECTOR2_FREELIST, FVector2, 512)
    NPFREELIST_ALLOC_INIT(NP_FVECTOR3_FREELIST, FVector3, 512)
    NPFREELIST_ALLOC_INIT(NP_FVECTOR4_FREELIST, FVector4, 512)

    NP_WORLDF_X_AXIS = fv3_alloc_init(); V_X(*NP_WORLDF_X_AXIS) = 1.0f;
    NP_WORLDF_Y_AXIS = fv3_alloc_init(); V_Y(*NP_WORLDF_Y_AXIS) = 1.0f;
    NP_WORLDF_Z_AXIS = fv3_alloc_init(); V_Z(*NP_WORLDF_Z_AXIS) = 1.0f;
    NP_WORLDF_FORWARD_VECTOR = fv3_alloc_init(); V_Z(*NP_WORLDF_FORWARD_VECTOR) = -1.0f;
}

FVector2 * fv2_alloc()
{
    return (FVector2 *)npfreenode_alloc(NP_FVECTOR2_FREELIST);
}

FVector2 * fv2_alloc_init()
{
    FVector2 * tmp = npfreenode_alloc(NP_FVECTOR2_FREELIST);
    V_X(*tmp) = V_Y(*tmp) = 0.0f;

    return tmp;
}

FVector2 * fv2_free(FVector2 * v)
{
    return npfreenode_free(v, NP_FVECTOR2_FREELIST);
}

void fv2_v_init_with_zeros(FVector2 * v)
{
    V_X(*v) = V_Y(*v) = 0.0f;
}

void fv2_vv_init_with_v2(FVector2 * v1, const FVector2 const * v2)
{
    V_X(*v1) = V_X(*v2);
    V_Y(*v1) = V_Y(*v2);
}

void fv2_vss_init_with_components(FVector2 * v, Float x, Float y)
{
    V_X(*v) = x;
    V_Y(*v) = y;
}

void fv2_v_invert(FVector2 * v)
{
    V_X(*v) = -V_X(*v);
    V_Y(*v) = -V_Y(*v);
}

void fv2_v_invert_v(const FVector2 const * v, FVector2 * result)
{
    V_X(*result) = -V_X(*v);
    V_Y(*result) = -V_Y(*v);
}

void fv2_v_normalise_v(const FVector2 * const v, FVector2 * normalised)
{
    Float length = fv2_v_length(v);
    V_X(*normalised) = V_X(*v)/length;
    V_Y(*normalised) = V_Y(*v)/length;
}

void fv2_v_normalise(FVector2 * v)
{
    Float length = fv2_v_length(v);
    V_X(*v) = V_X(*v) / length;
    V_Y(*v) = V_Y(*v) / length;
}

void fv2_sv_scale(Float scale, FVector2 * v)
{
    V_X(*v) *= scale;
    V_Y(*v) *= scale;
}

void fv2_sv_scalex(Float scale, FVector2 * v)
{
    V_X(*v) *= scale;
}

void fv2_sv_scaley(Float scale, FVector2 * v)
{
    V_Y(*v) *= scale;
}

void fv2_sv_scale_v(Float scale, const FVector2 * const v, FVector2 * result)
{
    V_X(*result) = V_X(*v) * scale;
    V_Y(*result) = V_Y(*v) * scale;
}

void fv2_sv_scalex_v(Float scale, const FVector2 * const v, FVector2 * result)
{
    V_X(*result) = V_X(*v) * scale;
}

void fv2_sv_scaley_v(Float scale, const FVector2 * const v, FVector2 * result)
{
    V_Y(*result) = V_Y(*v) * scale;
}

void fv2_vv_add_v(const FVector2 * const v, const FVector2 * const w, FVector2 * result)
{
    V_X(*result) = V_X(*v) + V_X(*w);
    V_Y(*result) = V_Y(*v) + V_Y(*w);
}

void fv2_vv_sub_v(const FVector2 * const v, const FVector2 * const w, FVector2 * result)
{
    V_X(*result) = V_X(*v) - V_X(*w);
    V_Y(*result) = V_Y(*v) - V_Y(*w);
}

void fv2_vvs_lerp_v(const FVector2 * const v, const FVector2 * const w, const float u, FVector2 * result)
{
    result->x = v->x * (1.0f - u) + w->x * u;
    result->y = v->y * (1.0f - u) + w->y * u;
}

Float fv2_vv_dot_product(const FVector2 * const v, const FVector2 * const w)
{
    return ( V_X(*v) * V_X(*w) + V_Y(*v) * V_Y(*w) );
}

Float fv2_v_square_length(const FVector2 * const v)
{
    return ( V_X(*v) * V_X(*v) + V_Y(*v) * V_Y(*v) );
}

Float fv2_v_length(const FVector2 * const v)
{
    return sqrtf( V_X(*v) * V_X(*v) + V_Y(*v) * V_Y(*v) );
}

FVector2 fv2_v_inverted(const FVector2 * const v)
{
    return (FVector2){-V_X(*v), -V_Y(*v)};
}

FVector2 fv2_v_normalised(const FVector2 * const v)
{
    Float length = fv2_v_length(v);
    return (FVector2){ V_X(*v) / length, V_Y(*v) / length };
}

FVector2 fv2_vv_add(const FVector2 * const v, const FVector2 * const w)
{
    return (FVector2){V_X(*v) + V_X(*w), V_Y(*v) + V_Y(*w)};
}

FVector2 fv2_vv_sub(const FVector2 * const v, const FVector2 * const w)
{
    return (FVector2){V_X(*v) - V_X(*w), V_Y(*v) - V_Y(*w)};
}

FVector2 fv2_sv_scaled(Float scale, const FVector2 const * v)
{
    return (FVector2){V_X(*v) * scale, V_Y(*v) * scale};
}

FVector2 fv2_sv_scaledx(Float scale, const FVector2 const * v)
{
    return (FVector2){V_X(*v) * scale, V_Y(*v)};
}

FVector2 fv2_sv_scaledy(Float scale, const FVector2 const * v)
{
    return (FVector2){V_X(*v) * scale, V_Y(*v)};
}

FVector2 fv2_vvs_lerp(const FVector2 * const v, const FVector2 * const w, const float u)
{
    return
        (FVector2){ v->x * (1.0f - u) + w->x * u,
                    v->y * (1.0f - u) + w->y * u };
}

const char * fv2_v_to_string(const FVector2 * const v)
{
    char * fv2string;

    if ( asprintf(&fv2string, "(%f, %f)",V_X(*v),V_Y(*v)) < 0)
    {
        return NULL;
    }

    return fv2string;
}

//-----------------------------------------------------------------------------

FVector3 * fv3_alloc()
{
    return (FVector3 *)npfreenode_alloc(NP_FVECTOR3_FREELIST);
}

FVector3 * fv3_alloc_init()
{
    FVector3 * tmp = npfreenode_alloc(NP_FVECTOR3_FREELIST);
    V_X(*tmp) = V_Y(*tmp) = V_Z(*tmp) = 0.0;

    return tmp;
}

FVector3 * fv3_alloc_init_with_fv3(FVector3 * v)
{
    FVector3 * tmp = npfreenode_alloc(NP_FVECTOR3_FREELIST);
    *tmp = *v;

    return tmp;
}

FVector3 * fv3_alloc_init_with_components(Float x, Float y, Float z)
{
    FVector3 * tmp = npfreenode_alloc(NP_FVECTOR3_FREELIST);

    V_X(*tmp) = x;
    V_Y(*tmp) = y;
    V_Z(*tmp) = z;

    return tmp;
}

FVector3 * fv3_free(FVector3 * v)
{
    return npfreenode_free(v, NP_FVECTOR3_FREELIST);
}

void fv3_v_init_with_zeros(FVector3 * v)
{
    V_X(*v) = V_Y(*v) = V_Z(*v) = 0.0f;
}

void fv3_vv_init_with_fv3(FVector3 * v1, const FVector3 const * v2)
{
    V_X(*v1) = V_X(*v2);
    V_Y(*v1) = V_Y(*v2);
    V_Z(*v1) = V_Z(*v2);
}

void fv3_vsss_init_with_components(FVector3 * v, Float x, Float y, Float z)
{
    V_X(*v) = x;
    V_Y(*v) = y;
    V_Z(*v) = z;
}

void fv3_v_invert(FVector3 * v)
{
    V_X(*v) = -V_X(*v);
    V_Y(*v) = -V_Y(*v);
    V_Z(*v) = -V_Z(*v);
}

void fv3_v_invert_v(const FVector3 const * v, FVector3 * result)
{
    V_X(*result) = -V_X(*v);
    V_Y(*result) = -V_Y(*v);
    V_Z(*result) = -V_Z(*v);    
}

void fv3_v_normalise_v(const FVector3 * const v, FVector3 * normalised)
{
    Float length = fv3_v_length(v);
    V_X(*normalised) = V_X(*v) / length;
    V_Y(*normalised) = V_Y(*v) / length;
    V_Z(*normalised) = V_Z(*v) / length;
}

void fv3_v_normalise(FVector3 * v)
{
    Float length = fv3_v_length(v);
    V_X(*v) = V_X(*v) / length;
    V_Y(*v) = V_Y(*v) / length;
    V_Z(*v) = V_Z(*v) / length;
}

void fv3_sv_scale(Float scale, FVector3 * v)
{
    V_X(*v) *= scale;
    V_Y(*v) *= scale;
    V_Z(*v) *= scale;
}

void fv3_sv_scalex(Float scale, FVector3 * v)
{
    V_X(*v) *= scale;
}

void fv3_sv_scaley(Float scale, FVector3 * v)
{
    V_Y(*v) *= scale;
}

void fv3_sv_scalez(Float scale, FVector3 * v)
{
    V_Z(*v) *= scale;
}

void fv3_sv_scale_v(Float scale, const FVector3 * const v, FVector3 * result)
{
    V_X(*result) = V_X(*v) * scale;
    V_Y(*result) = V_Y(*v) * scale;
    V_Z(*result) = V_Z(*v) * scale;
}

void fv3_sv_scalex_v(Float scale, const FVector3 * const v, FVector3 * result)
{
    V_X(*result) = V_X(*v) * scale;
}

void fv3_sv_scaley_v(Float scale, const FVector3 * const v, FVector3 * result)
{
    V_Y(*result) = V_Y(*v) * scale;
}

void fv3_sv_scalez_v(Float scale, const FVector3 * const v, FVector3 * result)
{
    V_Z(*result) = V_Z(*v) * scale;
}

void fv3_vv_add_v(const FVector3 * const v, const FVector3 * const w, FVector3 * result)
{
    V_X(*result) = V_X(*v) + V_X(*w);
    V_Y(*result) = V_Y(*v) + V_Y(*w);
    V_Z(*result) = V_Z(*v) + V_Z(*w);
}

void fv3_vv_sub_v(const FVector3 * const v, const FVector3 * const w, FVector3 * result)
{
    V_X(*result) = V_X(*v) - V_X(*w);
    V_Y(*result) = V_Y(*v) - V_Y(*w);
    V_Z(*result) = V_Z(*v) - V_Z(*w);
}

void fv3_vv_cross_product_v(const FVector3 * const v, const FVector3 * const w, FVector3 * cross)
{
    V_X(*cross) = V_Y(*v) * V_Z(*w) - V_Z(*v) * V_Y(*w);
    V_Y(*cross) = V_Z(*v) * V_X(*w) - V_X(*v) * V_Z(*w);
    V_Z(*cross) = V_X(*v) * V_Y(*w) - V_Y(*v) * V_X(*w);
}

void fv3_vvs_lerp_v(const FVector3 * const v, const FVector3 * const w, const float u, FVector3 * result)
{
    result->x = v->x * (1.0f - u) + w->x * u;
    result->y = v->y * (1.0f - u) + w->y * u;
    result->z = v->z * (1.0f - u) + w->z * u;
}

Float fv3_vv_dot_product(const FVector3 * const v, const FVector3 * const w)
{
    return ( V_X(*v) * V_X(*w) + V_Y(*v) * V_Y(*w) + V_Z(*v) * V_Z(*w) );
}

Float fv3_v_square_length(const FVector3 * const v)
{
    return ( V_X(*v) * V_X(*v) + V_Y(*v) * V_Y(*v) + V_Z(*v) * V_Z(*v) );
}

Float fv3_v_length(const FVector3 * const v)
{
    return sqrtf( V_X(*v) * V_X(*v) + V_Y(*v) * V_Y(*v) + V_Z(*v) * V_Z(*v) );
}

Float fv3_vv_square_distance(const FVector3 * const v, const FVector3 * const w)
{
    FVector3 sub = fv3_vv_sub(v, w);

    return fv3_v_square_length(&sub);
}

Float fv3_vv_distance(const FVector3 * const v, const FVector3 * const w)
{
    FVector3 sub = fv3_vv_sub(v, w);

    return fv3_v_length(&sub);
}

FVector3 fv3_v_inverted(const FVector3 * const v)
{
    return (FVector3){ -V_X(*v), -V_Y(*v), -V_Z(*v) };
}

FVector3 fv3_v_normalised(const FVector3 * const v)
{
    Float length = fv3_v_length(v);

    return (FVector3){ V_X(*v) / length, V_Y(*v) / length, V_Z(*v) / length };
}

FVector3 fv3_vv_add(const FVector3 * const v, const FVector3 * const w)
{
    return (FVector3){ V_X(*v) + V_X(*w), V_Y(*v) + V_Y(*w), V_Z(*v) + V_Z(*w) };
}

FVector3 fv3_vv_sub(const FVector3 * const v, const FVector3 * const w)
{
    return (FVector3){ V_X(*v) - V_X(*w), V_Y(*v) - V_Y(*w), V_Z(*v) - V_Z(*w) };
}

FVector3 fv3_vv_cross_product(const FVector3 * const v, const FVector3 * const w)
{
    return (FVector3){ V_Y(*v) * V_Z(*w) - V_Z(*v) * V_Y(*w),
                       V_Z(*v) * V_X(*w) - V_X(*v) * V_Z(*w),
                       V_X(*v) * V_Y(*w) - V_Y(*v) * V_X(*w) };
}

FVector3 fv3_sv_scaled(Float scale, const FVector3 const * v)
{
    return (FVector3){ V_X(*v) * scale, V_Y(*v) * scale, V_Z(*v) * scale };
}

FVector3 fv3_sv_scaledx(Float scale, const FVector3 const * v)
{
    return (FVector3){ V_X(*v) * scale, V_Y(*v), V_Z(*v) };
}

FVector3 fv3_sv_scaledy(Float scale, const FVector3 const * v)
{
    return (FVector3){ V_X(*v), V_Y(*v) * scale, V_Z(*v) };
}

FVector3 fv3_sv_scaledz(Float scale, const FVector3 const * v)
{
    return (FVector3){ V_X(*v), V_Y(*v), V_Z(*v) * scale };
}

FVector3 fv3_vvs_lerp(const FVector3 * const v, const FVector3 * const w, const float u)
{
    return
        (FVector3){ v->x * (1.0f - u) + w->x * u,
                    v->y * (1.0f - u) + w->y * u,
                    v->z * (1.0f - u) + w->z * u };
}

const char * fv3_v_to_string(const FVector3 * const v)
{
    char * fv3string;

    if ( asprintf(&fv3string, "(%f, %f, %f)",V_X(*v),V_Y(*v),V_Z(*v)) < 0)
    {
        return NULL;
    }

    return fv3string;
}

//-----------------------------------------------------------------------------

FVector4 * fv4_alloc()
{
    return (FVector4 *)npfreenode_alloc(NP_FVECTOR4_FREELIST);
}

FVector4 * fv4_alloc_init()
{
    FVector4 * tmp = npfreenode_alloc(NP_FVECTOR4_FREELIST);
    V_X(*tmp) = V_Y(*tmp) = V_Z(*tmp) = 0.0f;
    V_W(*tmp) = 1.0f;

    return tmp;
}

FVector4 * fv4_alloc_init_with_fv3(const FVector3 const * v)
{
    FVector4 * tmp = npfreenode_alloc(NP_FVECTOR4_FREELIST);
    V_X(*tmp) = V_X(*v);
    V_Y(*tmp) = V_Y(*v);
    V_Z(*tmp) = V_Z(*v);

    return tmp;
}

FVector4 * fv4_alloc_init_with_fv4(const FVector4 const * v)
{
    FVector4 * tmp = npfreenode_alloc(NP_FVECTOR4_FREELIST);
    V_X(*tmp) = V_X(*v);
    V_Y(*tmp) = V_Y(*v);
    V_Z(*tmp) = V_Z(*v);
    V_W(*tmp) = V_W(*v);

    return tmp;
}

FVector4 * fv4_alloc_init_with_components(Float x, Float y, Float z, Float w)
{
    FVector4 * tmp = npfreenode_alloc(NP_FVECTOR4_FREELIST);
    V_X(*tmp) = x;
    V_Y(*tmp) = y;
    V_Z(*tmp) = z;
    V_W(*tmp) = w;

    return tmp;
}

FVector4 * fv4_free(FVector4 * v)
{
    return npfreenode_free(v, NP_FVECTOR4_FREELIST);
}

void fv4_v_init_with_zeros(FVector4 * v)
{
    V_X(*v) = V_Y(*v) = V_Z(*v) = V_W(*v) = 0.0f;
}

void fv4_vv_init_with_fv3(FVector4 * v1, const FVector3 const * v2)
{
    V_X(*v1) = V_X(*v2);
    V_Y(*v1) = V_Y(*v2);
    V_Z(*v1) = V_Z(*v2);
    V_W(*v1) = 1.0f;
}

void fv4_vssss_init_with_components(FVector4 * v, Float x, Float y, Float z, Float w)
{
    V_X(*v) = x;
    V_Y(*v) = y;
    V_Z(*v) = z;
    V_W(*v) = w;
}

void fv4_v_homogenise(FVector4 * v)
{
    V_X(*v) = V_X(*v) / V_W(*v);
    V_Y(*v) = V_Y(*v) / V_W(*v);
    V_Z(*v) = V_Z(*v) / V_W(*v);
    V_W(*v) = 1.0f;
}

void fv4_v_homogenise_v(const FVector4 const * v, FVector4 * result)
{
    V_X(*result) = V_X(*v) / V_W(*v);
    V_Y(*result) = V_Y(*v) / V_W(*v);
    V_Z(*result) = V_Z(*v) / V_W(*v);
    V_W(*result) = 1.0f;
}

void fv4_sv_scale(Float scale, FVector4 * v)
{
    V_X(*v) = V_X(*v) * scale;
    V_Y(*v) = V_Y(*v) * scale;
    V_Z(*v) = V_Z(*v) * scale;
    V_W(*v) = V_W(*v) * scale;
}

void fv4_sv_scale_v(Float scale, const FVector4 * const v, FVector4 * result)
{
    V_X(*result) = V_X(*v) * scale;
    V_Y(*result) = V_Y(*v) * scale;
    V_Z(*result) = V_Z(*v) * scale;
    V_W(*result) = V_W(*v) * scale;
}

void fv4_vv_add_v(const FVector4 * const v, const FVector4 * const w, FVector4 * result)
{
    V_X(*result) = V_X(*v) + V_X(*w);
    V_Y(*result) = V_Y(*v) + V_Y(*w);
    V_Z(*result) = V_Z(*v) + V_Z(*w);
    V_W(*result) = V_W(*v) + V_W(*w);
}

void fv4_vv_sub_v(const FVector4 * const v, const FVector4 * const w, FVector4 * result)
{
    V_X(*result) = V_X(*v) - V_X(*w);
    V_Y(*result) = V_Y(*v) - V_Y(*w);
    V_Z(*result) = V_Z(*v) - V_Z(*w);
    V_W(*result) = V_W(*v) - V_W(*w);
}

FVector4 fv4_v_from_fv3(const FVector3 * const v)
{
    return (FVector4){ V_X(*v), V_Y(*v), V_Z(*v), 1.0f };
}

FVector4 fv4_v_homogenised(const FVector4 * const v)
{
    return (FVector4){ V_X(*v) / V_W(*v), V_Y(*v) / V_W(*v),
                       V_Z(*v) / V_W(*v), 1.0f };
}

FVector4 fv4_vv_add(const FVector4 * const v, const FVector4 * const w)
{
    return (FVector4){ V_X(*v) + V_X(*w), V_Y(*v) + V_Y(*w),
                       V_Z(*v) + V_Z(*w), V_W(*v) + V_W(*w) };
}

FVector4 fv4_vv_sub(const FVector4 * const v, const FVector4 * const w)
{
    return (FVector4){ V_X(*v) - V_X(*w), V_Y(*v) - V_Y(*w),
                       V_Z(*v) - V_Z(*w), V_W(*v) - V_W(*w) };
}

const char * fv4_v_to_string(const FVector4 * const v)
{
    char * fv4string;

    if ( asprintf(&fv4string, "(%f, %f, %f, %f)", V_X(*v), V_Y(*v), V_Z(*v), V_W(*v)) < 0 )
    {
        return NULL;
    }

    return fv4string;
}


