#ifndef _NP_MATH_FVECTOR_H_
#define _NP_MATH_FVECTOR_H_

#include "Core/Basics/NpTypes.h"
#include "Core/Basics/NpFreeList.h"

extern NpFreeList * NP_FVECTOR2_FREELIST;
extern NpFreeList * NP_FVECTOR3_FREELIST;
extern NpFreeList * NP_FVECTOR4_FREELIST;

void npmath_fvector_initialise();

typedef struct FVector2
{
    Float x, y;
}
FVector2;

typedef struct FVector3
{
    Float x, y, z;
}
FVector3;

typedef struct FVector4
{
    Float x, y, z, w;
}
FVector4;

#define FVECTOR_X(_v)    (_v).x
#define FVECTOR_Y(_v)    (_v).y
#define FVECTOR_Z(_v)    (_v).z
#define FVECTOR_W(_v)    (_v).w

#define FV_X FVECTOR_X
#define FV_Y FVECTOR_Y
#define FV_Z FVECTOR_Z
#define FV_W FVECTOR_W

extern FVector3 * NP_WORLDF_X_AXIS;
extern FVector3 * NP_WORLDF_Y_AXIS;
extern FVector3 * NP_WORLDF_Z_AXIS;
extern FVector3 * NP_WORLDF_FORWARD_VECTOR;

FVector2 * fv2_alloc();
FVector2 * fv2_alloc_init();
FVector2 * fv2_free(FVector2 * v);
void fv2_v_square_length_s(const FVector2 * const v, Float * sqrlength);
void fv2_v_length_s(const FVector2 * const v, Float * length);
void fv2_v_normalise_v(const FVector2 * const v, FVector2 * normalised);
void fv2_v_normalise(FVector2 * v);
void fv2_sv_scale(FVector2 * v, const Float * const scale);
void fv2_sv_scalex(FVector2 * v, const Float * const scale);
void fv2_sv_scaley(FVector2 * v, const Float * const scale);
void fv2_sv_scale_v(const FVector2 * const v, const Float * const scale, FVector2 * result);
void fv2_sv_scalex_v(const FVector2 * const v, const Float * const scale, FVector2 * result);
void fv2_sv_scaley_v(const FVector2 * const v, const Float * const scale, FVector2 * result);
void fv2_vv_add_v(const FVector2 * const v, const FVector2 * const w, FVector2 * result);
void fv2_vv_sub_v(const FVector2 * const v, const FVector2 * const w, FVector2 * result);
void fv2_vv_dot_product_s(const FVector2 * const v, const FVector2 * const w, Float * dot);
Float fv2_v_square_length(const FVector2 * const v);
Float fv2_v_length(const FVector2 * const v);
Float fv2_vv_dot_product(const FVector2 * const v, const FVector2 * const w);

FVector3 * fv3_alloc();
FVector3 * fv3_alloc_init();
FVector3 * fv3_free(FVector3 * v);
void fv3_v_zeros(FVector3 * v);
void fv3_v_invert(FVector3 * v);
void fv3_v_invert_v(FVector3 * v, FVector3 * w);
void fv3_v_square_length_s(const FVector3 * const v, Float * sqrlength);
void fv3_v_length_s(const FVector3 * const v, Float * length);
void fv3_v_normalise_v(const FVector3 * const v, FVector3 * normalised);
void fv3_v_normalise(FVector3 * v);
void fv3_sv_scale(FVector3 * v, const Float * const scale);
void fv3_sv_scalex(FVector3 * v, const Float * const scale);
void fv3_sv_scaley(FVector3 * v, const Float * const scale);
void fv3_sv_scalez(FVector3 * v, const Float * const scale);
void fv3_sv_scale_v(const FVector3 * const v, const Float * const scale, FVector3 * result);
void fv3_sv_scalex_v(const FVector3 * const v, const Float * const scale, FVector3 * result);
void fv3_sv_scaley_v(const FVector3 * const v, const Float * const scale, FVector3 * result);
void fv3_sv_scalez_v(const FVector3 * const v, const Float * const scale, FVector3 * result);
void fv3_vv_add_v(const FVector3 * const v, const FVector3 * const w, FVector3 * result);
void fv3_vv_sub_v(const FVector3 * const v, const FVector3 * const w, FVector3 * result);
void fv3_vv_dot_product_s(const FVector3 * const v, const FVector3 * const w, Float * dot);
void fv3_vv_cross_product_v(const FVector3 * const v, const FVector3 * const w, FVector3 * cross);
Float fv3_v_square_length(const FVector3 * const v);
Float fv3_v_length(const FVector3 * const v);
Float fv3_vv_dot_product(const FVector3 * const v, const FVector3 * const w);

FVector4 * fv4_alloc();
FVector4 * fv4_alloc_init();
FVector4 * fv4_free(FVector4 * v);
FVector4 * fv4_alloc_init_with_fvector3(FVector3 * v);
void fv4_vv_load_fv3(FVector4 * v, const FVector3 * const w);

#endif

