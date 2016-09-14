#ifndef _NP_MATH_FTRIANGLE_H_
#define _NP_MATH_FTRIANGLE_H_

#include "Core/Basics/NpTypes.h"
#include "Accessors.h"
#include "FVector.h"

void npmath_ftriangle_initialise(void);

typedef struct FTriangle
{
    FVector2 a;
    FVector2 b;
    FVector2 c;
}
FTriangle;

FTriangle * ftriangle_alloc(void);
FTriangle * ftriangle_alloc_init(void);
void ftriangle_free(FTriangle * t);

void ftriangle_tvvv_init_with_vertices(FTriangle * triangle,
    const FVector2 * const a,
    const FVector2 * const b,
    const FVector2 * const c);

int32_t ftriangle_vt_is_point_inside(const FVector2 * const point,
    const FTriangle * const triangle);


#endif

