#ifndef _NP_MATH_IBBOX_H_
#define _NP_MATH_IBBOX_H_

#include "Core/Basics/NpBasics.h"
#include "IVector.h"

void npmath_ibbox_initialise(void);

typedef struct IBBox
{
    IVector3 min;
    IVector3 max;
}
IBBox;

IBBox * ibbox_alloc(void);
IBBox * ibbox_alloc_init(void);
void ibbox_free(IBBox * bbox);

#endif
