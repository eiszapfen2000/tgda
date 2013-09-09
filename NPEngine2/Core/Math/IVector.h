#ifndef _NP_MATH_IVECTOR_H_
#define _NP_MATH_IVECTOR_H_

#include "Core/Basics/NpTypes.h"
#include "Accessors.h"

void npmath_ivector_initialise(void);

typedef struct IVector2
{
    int32_t x, y;
}
IVector2;

typedef struct IVector3
{
    int32_t x, y, z;
}
IVector3;

typedef struct IVector4
{
    int32_t x, y, z, w;
}
IVector4;

IVector2 * iv2_alloc(void);
IVector2 * iv2_alloc_init(void);
IVector2 * iv2_alloc_init_with_components(int32_t x, int32_t y);
void iv2_free(IVector2 * v);

IVector2 iv2_min(void);
IVector2 iv2_max(void);

IVector3 * iv3_alloc(void);
IVector3 * iv3_alloc_init(void);
IVector3 * iv3_alloc_init_with_components(int32_t x, int32_t y, int32_t z);
void iv3_free(IVector3 * v);

IVector3 iv3_min(void);
IVector3 iv3_max(void);


#endif
