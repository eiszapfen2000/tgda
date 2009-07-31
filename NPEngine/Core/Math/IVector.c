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

void iv2_v_copy_v(IVector2 * source, IVector2 * target)
{
    V_X(*target) = V_X(*source);
    V_Y(*target) = V_Y(*source);
}

IVector2 * iv2_free(IVector2 * v)
{
    return npfreenode_free(v, NP_IVECTOR2_FREELIST);
}


IVector3 * iv3_alloc()
{
    return (IVector3 *)npfreenode_alloc(NP_IVECTOR3_FREELIST);
}

IVector3 * iv3_alloc_init()
{
    IVector3 * tmp = npfreenode_alloc(NP_IVECTOR3_FREELIST);
    V_X(*tmp) = V_Y(*tmp) = V_Z(*tmp) = 0;

    return tmp;
}

IVector3 * iv3_alloc_init_with_iv2(IVector3 * v)
{
    IVector3 * tmp = npfreenode_alloc(NP_IVECTOR3_FREELIST);
    V_X(*tmp) = V_X(*v);
    V_Y(*tmp) = V_Y(*v);
    V_Z(*tmp) = V_Z(*v);

    return tmp;
}

IVector3 * iv3_alloc_init_with_components(Int x, Int y, Int z)
{
    IVector3 * tmp = npfreenode_alloc(NP_IVECTOR3_FREELIST);
    V_X(*tmp) = x;
    V_Y(*tmp) = y;
    V_Z(*tmp) = z;

    return tmp;
}

void iv3_v_copy_v(IVector3 * source, IVector3 * target)
{
    V_X(*target) = V_X(*source);
    V_Y(*target) = V_Y(*source);
    V_Z(*target) = V_Z(*source);
}

IVector3 * iv3_free(IVector3 * v)
{
    return npfreenode_free(v, NP_IVECTOR3_FREELIST);
}
