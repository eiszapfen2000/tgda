#ifndef _NP_BASICS_FREELIST_H_
#define _NP_BASICS_FREELIST_H_

#include "Types.h"
#include "Memory.h"

typedef struct NpFreeNode
{
    struct NpFreeNode  * next;
}
NpFreeNode;

#define NPFREENODE_NEXT(_node)  (_node).next

typedef struct NpFreeList
{
    NpFreeNode     * free;            /* slot list */
    NpFreeNode     * node;            /* block list */
    ULong            elementsize;
    ULong            blocksize;
#ifdef DEBUG
    ULong           allocated;
#endif
}
NpFreeList;

#define NPFREELIST_FREE(_list)          (_list).free
#define NPFREELIST_NODE(_list)          (_list).node
#define NPFREELIST_ELEMENT_SIZE(_list)  (_list).elementsize
#define NPFREELIST_BLOCK_SIZE(_list)    (_list).blocksize

#ifdef DEBUG
    #define NPFREELIST_ALLOCATED(_list) (_list).allocated
#endif

/* ---------------------------------------------------------------------------
    'NPFREELIST'
        Construct a freelist for a given type and a given blocksize.
--------------------------------------------------------------------------- */
#ifdef DEBUG
#define NPFREELIST(_type,_blocksize) \
                ((NpFreeList){ NULL, NULL, sizeof(_type), (_blocksize), 0 })
#else
#define NPFREELIST(_type,_blocksize) \
                ((NpFreeList){ NULL, NULL, sizeof(_type), (_blocksize) })
#endif

ArFreeNode * arfreelist_refill(ArFreeList  * freelist);


#ifdef DEBUG
#define NPFREELIST_INC_ALLOCATED(_freelist) (++(_freelist)->allocated)
#define NPFREELIST_DEC_ALLOCATED(_freelist) (--(_freelist)->allocated)
#define NPFREELIST_ALLOCATED(_freelist)     ((_freelist).allocated)
#else
#define NPFREELIST_INC_ALLOCATED(_freelist)
#define NPFREELIST_DEC_ALLOCATED(_freelist)
#define NPFREELIST_ALLOCATED(_freelist)     0
#endif


/* ---------------------------------------------------------------------------
    'arfreenode_alloc'
        Allocate a node by popping it from the freelist.  If the freelist is
        empty a new block of nodes is allocated.
--------------------------------------------------------------------------- */
ART_INLINE void * arfreenode_alloc(
        ArFreeList  * freelist
        )
{
    ArFreeNode * free = freelist->free;
    if (! free) free = arfreelist_refill(freelist);
    freelist->free = freelist->free->next;
    ARFREELIST_INC_ALLOCATED(freelist);
    return (void *)free;
}

/* ---------------------------------------------------------------------------
    'arfreenode_fast_free'
        Frees a node by pushing it onto the freelist.  The pointer to the
        node must be valid - it is not checked against 0.
--------------------------------------------------------------------------- */
ART_INLINE void * arfreenode_fast_free(
        void        * node, 
        ArFreeList  * freelist
        )
{
    ARFREELIST_DEC_ALLOCATED(freelist);
    ((ArFreeNode *)node)->next = freelist->free;
    freelist->free = (ArFreeNode *)node;
    return 0;
}

void arfreelist_free(
        ArFreeList  * freelist
        );


#endif
