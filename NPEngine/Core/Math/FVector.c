#define _GNU_SOURCE
#include <stdio.h>
#include <math.h>

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
    NPFREELIST_ALLOC_INIT(NP_FVECTOR2_FREELIST,FVector2,512)
    NPFREELIST_ALLOC_INIT(NP_FVECTOR3_FREELIST,FVector3,512)
    NPFREELIST_ALLOC_INIT(NP_FVECTOR4_FREELIST,FVector4,512)

    NP_WORLDF_X_AXIS = fv3_alloc_init(); FV_X(*NP_WORLDF_X_AXIS) = 1.0f;
    NP_WORLDF_Y_AXIS = fv3_alloc_init(); FV_Y(*NP_WORLDF_Y_AXIS) = 1.0f;
    NP_WORLDF_Z_AXIS = fv3_alloc_init(); FV_Z(*NP_WORLDF_Z_AXIS) = 1.0f;
    NP_WORLDF_FORWARD_VECTOR = fv3_alloc_init(); FV_Z(*NP_WORLDF_FORWARD_VECTOR) = -1.0f;
}

FVector2 * fv2_alloc()
{
    return (FVector2 *)npfreenode_alloc(NP_FVECTOR2_FREELIST);
}

FVector2 * fv2_alloc_init()
{
    FVector2 * tmp = npfreenode_alloc(NP_FVECTOR2_FREELIST);
    FV_X(*tmp) = FV_Y(*tmp) = 0.0;

    return tmp;
}

FVector2 * fv2_free(FVector2 * v)
{
    return npfreenode_fast_free(v,NP_FVECTOR2_FREELIST);
}

void fv2_v_square_length_s(const FVector2 * const v, Float * sqrlength)
{
    *sqrlength = FV_X(*v) * FV_X(*v) + FV_Y(*v) * FV_Y(*v);
}

void fv2_v_length_s(const FVector2 * const v, Float * length)
{
    *length = sqrt(FV_X(*v) * FV_X(*v) + FV_Y(*v) * FV_Y(*v));
}

void fv2_v_normalise_v(const FVector2 * const v, FVector2 * normalised)
{
    Float length = fv2_v_length(v);
    FV_X(*normalised) = FV_X(*v)/length;
    FV_Y(*normalised) = FV_Y(*v)/length;
}

void fv2_v_normalise(FVector2 * v)
{
    Float length = fv2_v_length(v);
    FV_X(*v) = FV_X(*v)/length;
    FV_Y(*v) = FV_Y(*v)/length;
}

void fv2_sv_scale(FVector2 * v, const Float * const scale)
{
    FV_X(*v) *= *scale;
    FV_Y(*v) *= *scale;
}

void fv2_sv_scalex(FVector2 * v, const Float * const scale)
{
    FV_X(*v) *= *scale;
}

void fv2_sv_scaley(FVector2 * v, const Float * const scale)
{
    FV_Y(*v) *= *scale;
}

void fv2_sv_scale_v(const FVector2 * const v, const Float * const scale, FVector2 * result)
{
    FV_X(*result) = FV_X(*v) * *scale;
    FV_Y(*result) = FV_Y(*v) * *scale;
}

void fv2_sv_scalex_v(const FVector2 * const v, const Float * const scale, FVector2 * result)
{
    FV_X(*result) = FV_X(*v) * *scale;
}

void fv2_sv_scaley_v(const FVector2 * const v, const Float * const scale, FVector2 * result)
{
    FV_Y(*result) = FV_Y(*v) * *scale;
}

void fv2_vv_add_v(const FVector2 * const v, const FVector2 * const w, FVector2 * result)
{
    FV_X(*result) = FV_X(*v) + FV_X(*w);
    FV_Y(*result) = FV_Y(*v) + FV_Y(*w);
}

void fv2_vv_sub_v(const FVector2 * const v, const FVector2 * const w, FVector2 * result)
{
    FV_X(*result) = FV_X(*v) - FV_X(*w);
    FV_Y(*result) = FV_Y(*v) - FV_Y(*w);
}

void fv2_vv_dot_product_s(const FVector2 * const v, const FVector2 * const w, Float * dot)
{
    *dot = FV_X(*v) * FV_X(*w) + FV_Y(*v) * FV_Y(*w);
}

Float fv2_vv_dot_product(const FVector2 * const v, const FVector2 * const w)
{
    return ( FV_X(*v) * FV_X(*w) + FV_Y(*v) * FV_Y(*w) );
}

Float fv2_v_square_length(const FVector2 * const v)
{
    return ( FV_X(*v) * FV_X(*v) + FV_Y(*v) * FV_Y(*v) );
}

Float fv2_v_length(const FVector2 * const v)
{
    return sqrt(fv2_v_square_length(v));
}

const char * fv2_v_to_string(FVector2 * v)
{
    char * fv2string;

    if ( asprintf(&fv2string, "%f %f\n",FV_X(*v),FV_Y(*v)) < 0)
    {
        return NULL;
    }

    return fv2string;
}


FVector3 * fv3_alloc()
{
    return (FVector3 *)npfreenode_alloc(NP_FVECTOR3_FREELIST);
}

FVector3 * fv3_alloc_init()
{
    FVector3 * tmp = npfreenode_alloc(NP_FVECTOR3_FREELIST);
    FV_X(*tmp) = FV_Y(*tmp) = FV_Z(*tmp) = 0.0;

    return tmp;
}

FVector3 * fv3_free(FVector3 * v)
{
    return npfreenode_fast_free(v,NP_FVECTOR3_FREELIST);
}

void fv3_v_zeros(FVector3 * v)
{
    FV_X(*v) = FV_Y(*v) = FV_Z(*v) = 0.0f;
}

void fv3_v_invert(FVector3 * v)
{
    FV_X(*v) = -FV_X(*v);
    FV_Y(*v) = -FV_Y(*v);
    FV_Z(*v) = -FV_Z(*v);
}

void fv3_v_invert_v(FVector3 * v, FVector3 * w)
{
    FV_X(*w) = -FV_X(*v);
    FV_Y(*w) = -FV_Y(*v);
    FV_Z(*w) = -FV_Z(*v);    
}

void fv3_v_square_length_s(const FVector3 * const v, Float * sqrlength)
{
    *sqrlength = FV_X(*v) * FV_X(*v) + FV_Y(*v) * FV_Y(*v) + FV_Z(*v) * FV_Z(*v);
}

void fv3_v_length_s(const FVector3 * const v, Float * length)
{
    *length = sqrt(FV_X(*v) * FV_X(*v) + FV_Y(*v) * FV_Y(*v) + FV_Z(*v) * FV_Z(*v));
}

void fv3_v_normalise_v(const FVector3 * const v, FVector3 * normalised)
{
    Float length = fv3_v_length(v);
    FV_X(*normalised) = FV_X(*v)/length;
    FV_Y(*normalised) = FV_Y(*v)/length;
    FV_Z(*normalised) = FV_Z(*v)/length;
}

void fv3_v_normalise(FVector3 * v)
{
    Float length = fv3_v_length(v);
    FV_X(*v) = FV_X(*v)/length;
    FV_Y(*v) = FV_Y(*v)/length;
    FV_Z(*v) = FV_Z(*v)/length;
}

void fv3_sv_scale(FVector3 * v, const Float * const scale)
{
    FV_X(*v) *= *scale;
    FV_Y(*v) *= *scale;
    FV_Z(*v) *= *scale;
}

void fv3_sv_scalex(FVector3 * v, const Float * const scale)
{
    FV_X(*v) *= *scale;
}

void fv3_sv_scaley(FVector3 * v, const Float * const scale)
{
    FV_Y(*v) *= *scale;
}

void fv3_sv_scalez(FVector3 * v, const Float * const scale)
{
    FV_Z(*v) *= *scale;
}

void fv3_sv_scale_v(const FVector3 * const v, const Float * const scale, FVector3 * result)
{
    FV_X(*result) = FV_X(*v) * *scale;
    FV_Y(*result) = FV_Y(*v) * *scale;
    FV_Z(*result) = FV_Z(*v) * *scale;
}

void fv3_sv_scalex_v(const FVector3 * const v, const Float * const scale, FVector3 * result)
{
    FV_X(*result) = FV_X(*v) * *scale;
}

void fv3_sv_scaley_v(const FVector3 * const v, const Float * const scale, FVector3 * result)
{
    FV_Y(*result) = FV_Y(*v) * *scale;
}

void fv3_sv_scalez_v(const FVector3 * const v, const Float * const scale, FVector3 * result)
{
    FV_Z(*result) = FV_Z(*v) * *scale;
}

void fv3_vv_add_v(const FVector3 * const v, const FVector3 * const w, FVector3 * result)
{
    FV_X(*result) = FV_X(*v) + FV_X(*w);
    FV_Y(*result) = FV_Y(*v) + FV_Y(*w);
    FV_Z(*result) = FV_Z(*v) + FV_Z(*w);
}

void fv3_vv_sub_v(const FVector3 * const v, const FVector3 * const w, FVector3 * result)
{
    FV_X(*result) = FV_X(*v) - FV_X(*w);
    FV_Y(*result) = FV_Y(*v) - FV_Y(*w);
    FV_Z(*result) = FV_Z(*v) - FV_Z(*w);
}

void fv3_vv_dot_product_s(const FVector3 * const v, const FVector3 * const w, Float * dot)
{
    *dot = FV_X(*v) * FV_X(*w) + FV_Y(*v) * FV_Y(*w) + FV_Z(*v) * FV_Z(*w);
}

void fv3_vv_cross_product_v(const FVector3 * const v, const FVector3 * const w, FVector3 * cross)
{
    FV_X(*cross) = FV_Y(*v) * FV_Z(*w) - FV_Z(*v) * FV_Y(*w);
    FV_Y(*cross) = FV_Z(*v) * FV_X(*w) - FV_X(*v) * FV_Z(*w);
    FV_Z(*cross) = FV_X(*v) * FV_Y(*w) - FV_Y(*v) * FV_X(*w);
}

Float fv3_v_square_length(const FVector3 * const v)
{
    return ( FV_X(*v) * FV_X(*v) + FV_Y(*v) * FV_Y(*v) + FV_Z(*v) * FV_Z(*v) );
}

Float fv3_v_length(const FVector3 * const v)
{
    return sqrt(fv3_v_square_length(v));
}

Float fv3_vv_dot_product(const FVector3 * const v, const FVector3 * const w)
{
    return ( FV_X(*v) * FV_X(*w) + FV_Y(*v) * FV_Y(*w) + FV_Z(*v) * FV_Z(*w) );
}

const char * fv3_v_to_string(FVector3 * v)
{
    char * fv3string;

    if ( asprintf(&fv3string, "%f %f %f\n",FV_X(*v),FV_Y(*v),FV_Z(*v)) < 0)
    {
        return NULL;
    }

    return fv3string;
}

FVector4 * fv4_alloc()
{
    return (FVector4 *)npfreenode_alloc(NP_FVECTOR4_FREELIST);
}

FVector4 * fv4_alloc_init()
{
    FVector4 * tmp = npfreenode_alloc(NP_FVECTOR4_FREELIST);
    FV_X(*tmp) = FV_Y(*tmp) = FV_Z(*tmp) = 0.0;
    FV_W(*tmp) = 1.0;

    return tmp;
}

FVector4 * fv4_free(FVector4 * v)
{
    return npfreenode_fast_free(v,NP_FVECTOR4_FREELIST);
}

FVector4 * fv4_alloc_init_with_fvector3(FVector3 * v)
{
    FVector4 * tmp = npfreenode_alloc(NP_FVECTOR4_FREELIST);
    FV_X(*tmp) = FV_X(*v);
    FV_Y(*tmp) = FV_Y(*v);
    FV_Z(*tmp) = FV_Z(*v);

    return tmp;
}

void fv4_vv_load_fv3(FVector4 * v, const FVector3 * const w)
{
    FV_X(*v) = FV_X(*w);
    FV_Y(*v) = FV_Y(*w);
    FV_Z(*v) = FV_Z(*w);    
}

const char * fv4_v_to_string(FVector4 * v)
{
    char * fv4string;

    if ( asprintf(&fv4string, "%f %f %f %f\n",FV_X(*v),FV_Y(*v),FV_Z(*v),FV_W(*v)) < 0)
    {
        return NULL;
    }

    return fv4string;
}


