#include "IVector.h"

NpFreeList * NP_IVECTOR2_FREELIST = NULL;
NpFreeList * NP_IVECTOR3_FREELIST = NULL;
NpFreeList * NP_IVECTOR4_FREELIST = NULL;

void npmath_ivector_initialise()
{
    NPFREELIST_ALLOC_INIT(NP_IVECTOR2_FREELIST, IVector2, 512)
    NPFREELIST_ALLOC_INIT(NP_IVECTOR3_FREELIST, IVector3, 512)
    NPFREELIST_ALLOC_INIT(NP_IVECTOR4_FREELIST, IVector4, 512)
}

IVector2 * iv2_alloc()
{
    return (IVector2 *)npfreenode_alloc(NP_IVECTOR2_FREELIST);
}

IVector2 * iv2_alloc_init()
{
    IVector2 * tmp = npfreenode_alloc(NP_IVECTOR2_FREELIST);
    V_X(*tmp) = V_Y(*tmp) = 0;

    return tmp;
}

IVector2 * iv2_alloc_init_with_iv2(IVector2 * v)
{
    IVector2 * tmp = npfreenode_alloc(NP_IVECTOR2_FREELIST);
    V_X(*tmp) = V_X(*v);
    V_Y(*tmp) = V_Y(*v);

    return tmp;
}

IVector2 * iv2_alloc_init_with_components(Int x, Int y)
{
    IVector2 * tmp = npfreenode_alloc(NP_IVECTOR2_FREELIST);
    V_X(*tmp) = x;
    V_Y(*tmp) = y;

    return tmp;
}

IVector2 * iv2_free(IVector2 * v)
{
    return npfreenode_free(v, NP_IVECTOR2_FREELIST);
}
