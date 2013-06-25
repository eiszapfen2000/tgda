#include "Core/Basics/NpFreeList.h"
#include "IVector.h"

NpFreeList * NP_IVECTOR2_FREELIST = NULL;
NpFreeList * NP_IVECTOR3_FREELIST = NULL;
NpFreeList * NP_IVECTOR4_FREELIST = NULL;

void npmath_ivector_initialise(void)
{
    NPFREELIST_ALLOC_INIT(NP_IVECTOR2_FREELIST, IVector2, 512)
    NPFREELIST_ALLOC_INIT(NP_IVECTOR3_FREELIST, IVector3, 512)
    NPFREELIST_ALLOC_INIT(NP_IVECTOR4_FREELIST, IVector4, 512)
}

IVector2 * iv2_alloc(void)
{
    return (IVector2 *)npfreenode_alloc(NP_IVECTOR2_FREELIST);
}

IVector2 * iv2_alloc_init(void)
{
    IVector2 * tmp = npfreenode_alloc(NP_IVECTOR2_FREELIST);
    V_X(*tmp) = V_Y(*tmp) = 0;

    return tmp;
}

IVector2 * iv2_alloc_init_with_components(int32_t x, int32_t y)
{
    IVector2 * tmp = npfreenode_alloc(NP_IVECTOR2_FREELIST);
    V_X(*tmp) = x;
    V_Y(*tmp) = y;

    return tmp;
}

void iv2_free(IVector2 * v)
{
    npfreenode_free(v, NP_IVECTOR2_FREELIST);
}


IVector3 * iv3_alloc(void)
{
    return (IVector3 *)npfreenode_alloc(NP_IVECTOR3_FREELIST);
}

IVector3 * iv3_alloc_init(void)
{
    IVector3 * tmp = npfreenode_alloc(NP_IVECTOR3_FREELIST);
    V_X(*tmp) = V_Y(*tmp) = V_Z(*tmp) = 0;

    return tmp;
}

IVector3 * iv3_alloc_init_with_components(int32_t x, int32_t y, int32_t z)
{
    IVector3 * tmp = npfreenode_alloc(NP_IVECTOR3_FREELIST);
    V_X(*tmp) = x;
    V_Y(*tmp) = y;
    V_Z(*tmp) = z;

    return tmp;
}

void iv3_free(IVector3 * v)
{
    npfreenode_free(v, NP_IVECTOR3_FREELIST);
}

