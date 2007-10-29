#ifndef _NP_BASICS_FREELIST_H_
#define _NP_BASICS_FREELIST_H_

#include "Types.h"
#include "Memory.h"

/*! \struct NpFreeNode
	\brief  Freelist element

    Freelist element, containing a pointer to the next element
*/
typedef struct NpFreeNode
{
    struct NpFreeNode * next;
}
NpFreeNode;

#define NPFREENODE_NEXT(_node)  (_node).next


/*! \struct NpFreeList
    \brief  Freelist

    Freelist memory pool
*/
typedef struct NpFreeList
{
    NpFreeNode     * free;          /* slot list */
    NpFreeNode     * node;          /* block list */
    ULong            elementsize;   /* size in bytes of the stored type */
    ULong            blocksize;     /* elements per block */
#ifdef DEBUG
    ULong            allocated;     /* Allocated elements count */
#endif
}
NpFreeList;

#define NPFREELIST_FREE(_list)          (_list).free
#define NPFREELIST_NODE(_list)          (_list).node
#define NPFREELIST_ELEMENT_SIZE(_list)  (_list).elementsize
#define NPFREELIST_BLOCK_SIZE(_list)    (_list).blocksize

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

#define NPFREELIST_ALLOC_INIT(_freelist, _type, _blocksize) \
    (_freelist) = ALLOC(NpFreeList); \
    (_freelist)->free = (_freelist)->node = NULL; \
    (_freelist)->elementsize = sizeof(_type); \
    (_freelist)->blocksize = (_blocksize);

/* ---------------------------------------------------------------------------
    'npfreelist_free'
        Allocates an additional block.
--------------------------------------------------------------------------- */
NpFreeNode * npfreelist_alloc_block(NpFreeList * freelist);

/* ---------------------------------------------------------------------------
    'npfreelist_free'
        Frees the entire freelist.
--------------------------------------------------------------------------- */
void npfreelist_free(NpFreeList * freelist);

/* ---------------------------------------------------------------------------
    'npfreenode_alloc'
        Allocate a node by popping it from the freelist.  If the freelist is
        empty a new block of nodes is allocated.
--------------------------------------------------------------------------- */
void * npfreenode_alloc(NpFreeList  * freelist);

/* ---------------------------------------------------------------------------
    'npfreenode_fast_free'
        Frees a node by pushing it onto the freelist.  The pointer to the
        node must be valid - it is not checked against 0.
--------------------------------------------------------------------------- */
void * npfreenode_fast_free(void * node, NpFreeList  * freelist);

#endif //_NP_BASICS_FREELIST_H_
