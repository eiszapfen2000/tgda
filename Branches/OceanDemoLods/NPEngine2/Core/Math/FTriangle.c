#include "Core/Basics/NpFreeList.h"
#include "FTriangle.h"

NpFreeList * NP_FTRIANGLE_FREELIST = NULL;

void npmath_ftriangle_initialise(void)
{
    NPFREELIST_ALLOC_INIT(NP_FTRIANGLE_FREELIST, FTriangle, 512);
}
