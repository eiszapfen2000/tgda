#ifndef _NP_MATH_IVECTOR_H_
#define _NP_MATH_IVECTOR_H_

#include "Core/Basics/NpTypes.h"
#include "Core/Basics/NpFreeList.h"
#include "Accessors.h"

void npmath_ivector_initialise();

typedef struct IVector2
{
    Int x, y;
}
IVector2;

typedef struct IVector3
{
    Int x, y, z;
}
IVector3;

typedef struct IVector4
{
    Int x, y, z, w;
}
IVector4;

IVector2 * iv2_alloc();
IVector2 * iv2_alloc_init();
IVector2 * iv2_alloc_init_with_iv2(IVector2 * v);
IVector2 * iv2_alloc_init_with_components(Int x, Int y);
IVector2 * iv2_free(IVector2 * v);

void iv2_v_copy_v(IVector2 * source, IVector2 * target);

IVector3 * iv3_alloc();
IVector3 * iv3_alloc_init();
IVector3 * iv3_alloc_init_with_iv3(IVector3 * v);
IVector3 * iv3_alloc_init_with_components(Int x, Int y, Int z);
IVector3 * iv3_free(IVector3 * v);

void iv3_v_copy_v(IVector3 * source, IVector3 * target);

#endif
