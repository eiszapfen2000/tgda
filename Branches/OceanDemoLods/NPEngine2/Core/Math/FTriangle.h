#ifndef _NP_MATH_FTRIANGLE_H_
#define _NP_MATH_FTRIANGLE_H_

#include "Core/Basics/NpTypes.h"
#include "Accessors.h"
#include "FVector.h"

void npmath_ftriangle_initialise(void);

typedef struct FTriangle
{
    FVector3 a;
    FVector3 b;
    FVector3 c;
}
FTriangle;

#endif

