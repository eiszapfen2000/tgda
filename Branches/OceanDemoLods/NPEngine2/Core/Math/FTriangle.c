#include "Core/Basics/NpFreeList.h"
#include "FTriangle.h"

NpFreeList * NP_FTRIANGLE_FREELIST = NULL;

void npmath_ftriangle_initialise(void)
{
    NPFREELIST_ALLOC_INIT(NP_FTRIANGLE_FREELIST, FTriangle, 512);
}

FTriangle * ftriangle_alloc(void)
{
    return npfreenode_alloc(NP_FTRIANGLE_FREELIST);
}

FTriangle * ftriangle_alloc_init(void)
{
    FTriangle * triangle = npfreenode_alloc(NP_FTRIANGLE_FREELIST);

    triangle->a = fv2_zero();
    triangle->b = fv2_zero();
    triangle->c = fv2_zero();

    return triangle;
}

void ftriangle_free(FTriangle * t)
{
    npfreenode_free(t, NP_FTRIANGLE_FREELIST);
}

void ftriangle_tvvv_init_with_vertices(FTriangle * triangle,
    const FVector2 * const a,
    const FVector2 * const b,
    const FVector2 * const c)
{
    triangle->a = *a;
    triangle->b = *b;
    triangle->c = *c;
}
