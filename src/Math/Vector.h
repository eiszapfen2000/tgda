#ifndef _NP_MATH_VECTOR_H_
#define _NP_MATH_VECTOR_H_

#include "Basics/Types.h"

typedef struct
{
    Double x, y;
}
Vector2;

typedef struct
{
    Double x, y, z;
}
Vector3;

typedef struct
{
    Double x, y, z, w;
}
Vector4;

Double v2_v_square_length(const Vector2 * const v);

Double v2_v_length(const Vector2 * const v);

void v2_v_normalize_v(const Vector2 * const v, Vector2 * n);

void v2_v_normalize(Vector2 * v);

Double v2_vv_dot_product(const Vector2 * const v, const Vector2 * const w);


Double v3_v_square_length(const Vector3 * const v);

Double v3_v_length(const Vector3 * const v);

void v3_v_normalize_v(const Vector3 * const v, Vector3 * n);

void v3_v_normalize(Vector3 * v);

Double v3_vv_dot_product(const Vector3 * const v, const Vector3 * const w);

void v3_vv_cross_product_v(const Vector3 * const v, const Vector3 * const w, Vector3 * out);

#endif

