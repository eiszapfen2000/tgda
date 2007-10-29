#ifndef _NP_MATH_VECTOR_H_
#define _NP_MATH_VECTOR_H_

#include "Basics/Types.h"
#include "Basics/NpFreeList.h"

extern NpFreeList * NP_VECTOR2_FREELIST;
extern NpFreeList * NP_VECTOR3_FREELIST;
extern NpFreeList * NP_VECTOR4_FREELIST;

void npmath_vector_initialise();

typedef struct Vector2
{
    Double x, y;
}
Vector2;

typedef struct Vector3
{
    Double x, y, z;
}
Vector3;

typedef struct Vector4
{
    Double x, y, z, w;
}
Vector4;

#define VECTOR_X(_v)    (_v).x
#define VECTOR_Y(_v)    (_v).y
#define VECTOR_Z(_v)    (_v).z
#define VECTOR_W(_v)    (_v).w

#define V_X VECTOR_X
#define V_Y VECTOR_Y
#define V_Z VECTOR_Z
#define V_W VECTOR_W

void v2_v_square_length_s(const Vector2 * const v, Double * sqrlength);
void v2_v_length_s(const Vector2 * const v, Double * length);
void v2_v_normalise_v(const Vector2 * const v, Vector2 * normalised);
void v2_v_normalise(Vector2 * v);
void v2_sv_scale(Vector2 * v, const Double * const scale);
void v2_sv_scalex(Vector2 * v, const Double * const scale);
void v2_sv_scaley(Vector2 * v, const Double * const scale);
void v2_sv_scale_v(const Vector2 * const v, const Double * const scale, Vector2 * result);
void v2_sv_scalex_v(const Vector2 * const v, const Double * const scale, Vector2 * result);
void v2_sv_scaley_v(const Vector2 * const v, const Double * const scale, Vector2 * result);
void v2_vv_add_v(const Vector2 * const v, const Vector2 * const w, Vector2 * result);
void v2_vv_sub_v(const Vector2 * const v, const Vector2 * const w, Vector2 * result);
void v2_vv_dot_product_s(const Vector2 * const v, const Vector2 * const w, Double * dot);
Double v2_v_square_length(const Vector2 * const v);
Double v2_v_length(const Vector2 * const v);
Double v2_vv_dot_product(const Vector2 * const v, const Vector2 * const w);
Vector2 * v2_alloc();
Vector2 * v2_alloc_init();

void v3_v_square_length_s(const Vector3 * const v, Double * sqrlength);
void v3_v_length_s(const Vector3 * const v, Double * length);
void v3_v_normalise_v(const Vector3 * const v, Vector3 * normalised);
void v3_v_normalise(Vector3 * v);
void v3_sv_scale(Vector3 * v, const Double * const scale);
void v3_sv_scalex(Vector3 * v, const Double * const scale);
void v3_sv_scaley(Vector3 * v, const Double * const scale);
void v3_sv_scalez(Vector3 * v, const Double * const scale);
void v3_sv_scale_v(const Vector3 * const v, const Double * const scale, Vector3 * result);
void v3_sv_scalex_v(const Vector3 * const v, const Double * const scale, Vector3 * result);
void v3_sv_scaley_v(const Vector3 * const v, const Double * const scale, Vector3 * result);
void v3_sv_scalez_v(const Vector3 * const v, const Double * const scale, Vector3 * result);
void v3_vv_add_v(const Vector3 * const v, const Vector3 * const w, Vector3 * result);
void v3_vv_sub_v(const Vector3 * const v, const Vector3 * const w, Vector3 * result);
void v3_vv_dot_product_s(const Vector3 * const v, const Vector3 * const w, Double * dot);
void v3_vv_cross_product_v(const Vector3 * const v, const Vector3 * const w, Vector3 * cross);
Double v3_v_square_length(const Vector3 * const v);
Double v3_v_length(const Vector3 * const v);
Double v3_vv_dot_product(const Vector3 * const v, const Vector3 * const w);
Vector3 * v3_alloc();
Vector3 * v3_alloc_init();

#endif

