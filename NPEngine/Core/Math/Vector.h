#ifndef _NP_MATH_VECTOR_H_
#define _NP_MATH_VECTOR_H_

#include "Core/Basics/NpTypes.h"
#include "Core/Basics/NpFreeList.h"

void npmath_vector_initialise();

typedef struct IVector2
{
    Int x, y;
}
IVector2;

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

extern Vector3 * NP_WORLD_X_AXIS;
extern Vector3 * NP_WORLD_Y_AXIS;
extern Vector3 * NP_WORLD_Z_AXIS;
extern Vector3 * NP_WORLD_FORWARD_VECTOR;

Vector2 * v2_alloc();
Vector2 * v2_alloc_init();
Vector2 * v2_free(Vector2 * v);
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

Vector3 * v3_alloc();
Vector3 * v3_alloc_init();
Vector3 * v3_alloc_init_with_v3(Vector3 * v);
Vector3 * v3_free(Vector3 * v);
void v3_v_square_length_s(const Vector3 * const v, Double * sqrlength);
void v3_v_length_s(const Vector3 * const v, Double * length);
void v3_v_normalise_v(const Vector3 * const v, Vector3 * normalised);
void v3_v_normalise(Vector3 * v);
void v3_sv_scale(const Double * const scale, Vector3 * v);
void v3_sv_scalex(const Double * const scale, Vector3 * v);
void v3_sv_scaley(const Double * const scale, Vector3 * v);
void v3_sv_scalez(const Double * const scale, Vector3 * v);
void v3_sv_scale_v(const Double * const scale, const Vector3 * const v, Vector3 * result);
void v3_sv_scalex_v(const Double * const scale, const Vector3 * const v, Vector3 * result);
void v3_sv_scaley_v(const Double * const scale, const Vector3 * const v, Vector3 * result);
void v3_sv_scalez_v(const Double * const scale, const Vector3 * const v, Vector3 * result);
void v3_vv_add_v(const Vector3 * const v, const Vector3 * const w, Vector3 * result);
void v3_vv_sub_v(const Vector3 * const v, const Vector3 * const w, Vector3 * result);
void v3_vv_dot_product_s(const Vector3 * const v, const Vector3 * const w, Double * dot);
void v3_vv_cross_product_v(const Vector3 * const v, const Vector3 * const w, Vector3 * cross);
void v3_v_zeros(Vector3 * v);
Double v3_v_square_length(const Vector3 * const v);
Double v3_v_length(const Vector3 * const v);
Double v3_vv_dot_product(const Vector3 * const v, const Vector3 * const w);


Vector4 * v4_alloc();
Vector4 * v4_alloc_init();
Vector4 * v4_free(Vector4 * v);

#endif

