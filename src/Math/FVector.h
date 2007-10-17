#ifndef _NP_MATH_FVECTOR_H_
#define _NP_MATH_FVECTOR_H_

#include "Basics/Types.h"

typedef struct
{
    Float x, y;
}
FVector2;

typedef struct
{
    Float x, y, z;
}
FVector3;

typedef struct
{
    Float x, y, z, w;
}
FVector4;

Float fv2_v_square_length(const FVector2 * const v);
Float fv3_v_square_length(const FVector3 * const v);

Float fv2_v_length(const FVector2 * const v);
Float fv3_v_length(const FVector3 * const v);

void fv2_v_normalize_v(const FVector2 * const v, FVector2 * n);
void fv3_v_normalize_v(const FVector3 * const v, FVector3 * n);

void fv2_v_normalize(FVector2 * v);
void fv3_v_normalize(FVector3 * v);

Float fv2_vv_dot_product(const FVector2 * const v, const FVector2 * const w);
Float fv3_vv_dot_product(const FVector3 * const v, const FVector3 * const w);

void fv3_vv_cross_product_v(const FVector3 * const v, const FVector3 * const w, FVector3 * out);

#endif

