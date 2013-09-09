#ifndef _NP_MATH_VECTOR_H_
#define _NP_MATH_VECTOR_H_

#include "Core/Basics/NpTypes.h"
#include "Accessors.h"

void npmath_vector_initialise(void);

typedef struct Vector2
{
    double x, y;
}
Vector2;

typedef struct Vector3
{
    double x, y, z;
}
Vector3;

typedef struct Vector4
{
    double x, y, z, w;
}
Vector4;

extern Vector3 * NP_WORLD_X_AXIS;
extern Vector3 * NP_WORLD_Y_AXIS;
extern Vector3 * NP_WORLD_Z_AXIS;
extern Vector3 * NP_WORLD_FORWARD_VECTOR;

Vector2 * v2_alloc(void);
Vector2 * v2_alloc_init(void);
Vector2 * v2_alloc_init_with_components(double x, double y);
void v2_free(Vector2 * v);
void v2_v_init_with_zeros(Vector2 * v);
void v2_vss_init_with_components(Vector2 * v, double x, double y);
void v2_v_invert(Vector2 * v);
void v2_v_invert_v(const Vector2 * const v, Vector2 * result);
void v2_v_normalise_v(const Vector2 * const v, Vector2 * normalised);
void v2_v_normalise(Vector2 * v);
void v2_sv_scale(double scale, Vector2 * v);
void v2_sv_scalex(double scale, Vector2 * v);
void v2_sv_scaley(double scale, Vector2 * v);
void v2_sv_scale_v(double scale, const Vector2 * const v, Vector2 * result);
void v2_sv_scalex_v(double scale, const Vector2 * const v, Vector2 * result);
void v2_sv_scaley_v(double scale, const Vector2 * const v, Vector2 * result);
void v2_vv_add_v(const Vector2 * const v, const Vector2 * const w, Vector2 * result);
void v2_vv_sub_v(const Vector2 * const v, const Vector2 * const w, Vector2 * result);
double v2_vv_dot_product(const Vector2 * const v, const Vector2 * const w);
double v2_v_square_length(const Vector2 * const v);
double v2_v_length(const Vector2 * const v);
Vector2 v2_min(void);
Vector2 v2_max(void);
Vector2 v2_v_inverted(Vector2 * v);
Vector2 v2_v_normalised(const Vector2 * const v);
Vector2 v2_vv_add(const Vector2 * const v, const Vector2 * const w);
Vector2 v2_vv_sub(const Vector2 * const v, const Vector2 * const w);
Vector2 v2_sv_scaled(double scale, const Vector2 * const v);
Vector2 v2_sv_scaledx(double scale, const Vector2 * const v);
Vector2 v2_sv_scaledy(double scale, const Vector2 * const v);
const char * v2_v_to_string(Vector2 * v);

Vector3 * v3_alloc(void);
Vector3 * v3_alloc_init(void);
Vector3 * v3_alloc_init_with_components(double x, double y, double z);
void v3_free(Vector3 * v);
void v3_v_init_with_zeros(Vector3 * v);
void v3_vsss_init_with_components(Vector3 * v, double x, double y, double z);
void v3_v_invert(Vector3 * v);
void v3_v_invert_v(const Vector3 * const v, Vector3 * result);
void v3_v_normalise_v(const Vector3 * const v, Vector3 * normalised);
void v3_v_normalise(Vector3 * v);
void v3_sv_scale(double scale, Vector3 * v);
void v3_sv_scalex(double scale, Vector3 * v);
void v3_sv_scaley(double scale, Vector3 * v);
void v3_sv_scalez(double scale, Vector3 * v);
void v3_sv_scale_v(double scale, const Vector3 * const v, Vector3 * result);
void v3_sv_scalex_v(double scale, const Vector3 * const v, Vector3 * result);
void v3_sv_scaley_v(double scale, const Vector3 * const v, Vector3 * result);
void v3_sv_scalez_v(double scale, const Vector3 * const v, Vector3 * result);
void v3_vv_add_v(const Vector3 * const v, const Vector3 * const w, Vector3 * result);
void v3_vv_sub_v(const Vector3 * const v, const Vector3 * const w, Vector3 * result);
void v3_vv_cross_product_v(const Vector3 * const v, const Vector3 * const w, Vector3 * cross);
double v3_vv_dot_product(const Vector3 * const v, const Vector3 * const w);
double v3_v_square_length(const Vector3 * const v);
double v3_v_length(const Vector3 * const v);
Vector3 v3_min(void);
Vector3 v3_max(void);
Vector3 v3_v_inverted(Vector3 * v);
Vector3 v3_v_normalised(const Vector3 * const v);
Vector3 v3_vv_add(const Vector3 * const v, const Vector3 * const w);
Vector3 v3_vv_sub(const Vector3 * const v, const Vector3 * const w);
Vector3 v3_vv_cross_product(const Vector3 * const v, const Vector3 * const w);
Vector3 v3_sv_scaled(double scale, const Vector3 * const v);
Vector3 v3_sv_scaledx(double scale, const Vector3 * const v);
Vector3 v3_sv_scaledy(double scale, const Vector3 * const v);
Vector3 v3_sv_scaledz(double scale, const Vector3 * const v);
const char * v3_v_to_string(Vector3 * v);

Vector4 * v4_alloc(void);
Vector4 * v4_alloc_init(void);
Vector4 * v4_alloc_init_with_v3(const Vector3 * const v);
Vector4 * v4_alloc_init_with_components(double x, double y, double z, double w);
void v4_free(Vector4 * v);
void v4_v_init_with_zeros(Vector4 * v);
void v4_vv_init_with_v3(Vector4 * v1, const Vector3 * const v2);
void v4_vssss_init_with_components(Vector4 * v, double x, double y, double z, double w);
void v4_v_homogenise(Vector4 * v);
void v4_v_homogenise_v(const Vector4 * const v, Vector4 * result);
void v4_sv_scale(double scale, Vector4 * v);
void v4_sv_scale_v(double scale, const Vector4 * const v, Vector4 * result);
void v4_vv_sub_v(const Vector4 * const v, const Vector4 * const w, Vector4 * result);
void v4_vv_add_v(const Vector4 * const v, const Vector4 * const w, Vector4 * result);
Vector4 v4_v_homogenised(const Vector4 * const v);
Vector4 v4_vv_add(const Vector4 * const v, const Vector4 * const w);
Vector4 v4_vv_sub(const Vector4 * const v, const Vector4 * const w);
const char * v4_v_to_string(Vector4 * v);

#endif

