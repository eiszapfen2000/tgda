#ifndef _NP_MATH_FVECTOR_H_
#define _NP_MATH_FVECTOR_H_

#include "Core/Basics/NpTypes.h"
#include "Accessors.h"

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

typedef FVector3 FNormal;

typedef struct FVector4
{
    Float x, y, z, w;
}
FVector4;

extern FVector3 * NP_WORLDF_X_AXIS;
extern FVector3 * NP_WORLDF_Y_AXIS;
extern FVector3 * NP_WORLDF_Z_AXIS;
extern FVector3 * NP_WORLDF_FORWARD_VECTOR;

FVector2 * fv2_alloc();
FVector2 * fv2_alloc_init();
FVector2 * fv2_free(FVector2 * v);
void fv2_v_init_with_zeros(FVector2 * v);
void fv2_vv_init_with_fv2(FVector2 * v1, const FVector2 const * v2);
void fv2_vss_init_with_components(FVector2 * v, Float x, Float y);
void fv2_v_invert(FVector2 * v);
void fv2_v_invert_v(const FVector2 const * v, FVector2 * result);
void fv2_v_normalise_v(const FVector2 * const v, FVector2 * normalised);
void fv2_v_normalise(FVector2 * v);
void fv2_sv_scale(Float scale, FVector2 * v);
void fv2_sv_scalex(Float scale, FVector2 * v);
void fv2_sv_scaley(Float scale, FVector2 * v);
void fv2_sv_scale_v(Float scale, const FVector2 * const v, FVector2 * result);
void fv2_sv_scalex_v(Float scale, const FVector2 * const v, FVector2 * result);
void fv2_sv_scaley_v(Float scale, const FVector2 * const v, FVector2 * result);
void fv2_vv_add_v(const FVector2 * const v, const FVector2 * const w, FVector2 * result);
void fv2_vv_sub_v(const FVector2 * const v, const FVector2 * const w, FVector2 * result);
void fv2_vvs_lerp_v(const FVector2 * const v, const FVector2 * const w, const float u, FVector2 * result);
Float fv2_vv_dot_product(const FVector2 * const v, const FVector2 * const w);
Float fv2_v_square_length(const FVector2 * const v);
Float fv2_v_length(const FVector2 * const v);
FVector2 fv2_v_inverted(const FVector2 * const v);
FVector2 fv2_v_normalised(const FVector2 * const v);
FVector2 fv2_vv_add(const FVector2 * const v, const FVector2 * const w);
FVector2 fv2_vv_sub(const FVector2 * const v, const FVector2 * const w);
FVector2 fv2_sv_scaled(Float scale, const FVector2 const * v);
FVector2 fv2_sv_scaledx(Float scale, const FVector2 const * v);
FVector2 fv2_sv_scaledy(Float scale, const FVector2 const * v);
FVector2 fv2_vvs_lerp(const FVector2 * const v, const FVector2 * const w, const float u);
const char * fv2_v_to_string(const FVector2 * const v);

FVector3 * fv3_alloc();
FVector3 * fv3_alloc_init();
FVector3 * fv3_alloc_init_with_fv3(FVector3 * v);
FVector3 * fv3_alloc_init_with_components(Float x, Float y, Float z);
FVector3 * fv3_free(FVector3 * v);
void fv3_v_init_with_zeros(FVector3 * v);
void fv3_vv_init_with_fv3(FVector3 * v1, const FVector3 const * v2);
void fv3_vsss_init_with_components(FVector3 * v, Float x, Float y, Float z);
void fv3_v_invert(FVector3 * v);
void fv3_v_invert_v(const FVector3 const * v, FVector3 * result);
void fv3_v_normalise_v(const FVector3 * const v, FVector3 * normalised);
void fv3_v_normalise(FVector3 * v);
void fv3_sv_scale(Float scale, FVector3 * v);
void fv3_sv_scalex(Float scale, FVector3 * v);
void fv3_sv_scaley(Float scale, FVector3 * v);
void fv3_sv_scalez(Float scale, FVector3 * v);
void fv3_sv_scale_v(Float scale, const FVector3 * const v, FVector3 * result);
void fv3_sv_scalex_v(Float scale, const FVector3 * const v, FVector3 * result);
void fv3_sv_scaley_v(Float scale, const FVector3 * const v, FVector3 * result);
void fv3_sv_scalez_v(Float scale, const FVector3 * const v, FVector3 * result);
void fv3_vv_add_v(const FVector3 * const v, const FVector3 * const w, FVector3 * result);
void fv3_vv_sub_v(const FVector3 * const v, const FVector3 * const w, FVector3 * result);
void fv3_vv_cross_product_v(const FVector3 * const v, const FVector3 * const w, FVector3 * cross);
void fv3_vvs_lerp_v(const FVector3 * const v, const FVector3 * const w, const float u, FVector3 * result);
Float fv3_vv_dot_product(const FVector3 * const v, const FVector3 * const w);
Float fv3_v_square_length(const FVector3 * const v);
Float fv3_v_length(const FVector3 * const v);
Float fv3_vv_square_distance(const FVector3 * const v, const FVector3 * const w);
Float fv3_vv_distance(const FVector3 * const v, const FVector3 * const w);
FVector3 fv3_v_inverted(const FVector3 * const v);
FVector3 fv3_v_normalised(const FVector3 * const v);
FVector3 fv3_vv_add(const FVector3 * const v, const FVector3 * const w);
FVector3 fv3_vv_sub(const FVector3 * const v, const FVector3 * const w);
FVector3 fv3_vv_cross_product(const FVector3 * const v, const FVector3 * const w);
FVector3 fv3_sv_scaled(Float scale, const FVector3 const * v);
FVector3 fv3_sv_scaledx(Float scale, const FVector3 const * v);
FVector3 fv3_sv_scaledy(Float scale, const FVector3 const * v);
FVector3 fv3_sv_scaledz(Float scale, const FVector3 const * v);
FVector3 fv3_vvs_lerp(const FVector3 * const v, const FVector3 * const w, const float u);
const char * fv3_v_to_string(const FVector3 * const v);

FVector4 * fv4_alloc();
FVector4 * fv4_alloc_init();
FVector4 * fv4_alloc_init_with_fv3(const FVector3 const * v);
FVector4 * fv4_alloc_init_with_fv4(const FVector4 const * v);
FVector4 * fv4_alloc_init_with_components(Float x, Float y, Float z, Float w);
FVector4 * fv4_free(FVector4 * v);
void fv4_v_init_with_zeros(FVector4 * v);
void fv4_vv_init_with_fv3(FVector4 * v1, const FVector3 const * v2);
void fv4_vssss_init_with_components(FVector4 * v, Float x, Float y, Float z, Float w);
void fv4_v_homogenise(FVector4 * v);
void fv4_v_homogenise_v(const FVector4 const * v, FVector4 * result);
void fv4_sv_scale(Float scale, FVector4 * v);
void fv4_sv_scale_v(Float scale, const FVector4 * const v, FVector4 * result);
void fv4_vv_sub_v(const FVector4 * const v, const FVector4 * const w, FVector4 * result);
void fv4_vv_add_v(const FVector4 * const v, const FVector4 * const w, FVector4 * result);
FVector4 fv4_v_from_fv3(const FVector3 * const v);
FVector4 fv4_v_homogenised(const FVector4 * const v);
FVector4 fv4_vv_add(const FVector4 * const v, const FVector4 * const w);
FVector4 fv4_vv_sub(const FVector4 * const v, const FVector4 * const w);
const char * fv4_v_to_string(const FVector4 * const v);

#endif

