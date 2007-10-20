#include "NpFreeList.h"

void * npfreenode_alloc(NpFreeList  * freelist)
{
    NpFreeNode * free = NPFREELIST_FREE(*freelist);

    if (!free)
    {
        free = npfreelist_alloc_block(freelist);
    }

    NPFREELIST_FREE(*freelist) = NPFREENODE_NEXT(*NPFREELIST_FREE(*freelist));
    NPFREELIST_INC_ALLOCATED(freelist);

    return (void *)free;
}

void * npfreenode_fast_free(void * node, NpFreeList  * freelist)
{
    NPFREELIST_DEC_ALLOCATED(freelist);

    NPFREENODE_NEXT(*((NpFreeNode *)node)) = NPFREELIST_FREE(*freelist);
    NPFREELIST_FREE(*freelist) = (NpFreeNode *)node;

    return NULL;
}

NpFreeNode * npfreelist_alloc_block(NpFreeList * freelist)
{
    ULong tablelength = NPFREELIST_ELEMENT_SIZE(*freelist) * NPFREELIST_BLOCK_SIZE(*freelist);

    NpFreeNode * node = malloc(tablelength + sizeof(NpFreeNode));
    NpFreeNode * free = NULL;
    
    for ( unsigned int i = 0; i < NPFREELIST_BLOCK_SIZE(*freelist); i++)
    {
	    NPFREENODE_NEXT(*node) = free;
	    free = node;

        // cast to Byte* so that we can count bytewise
	    node = (NpFreeNode *)(((Byte *)node) + NPFREELIST_ELEMENT_SIZE(*freelist));
    }

    NPFREENODE_NEXT(*node) = NPFREELIST_NODE(*freelist);
    NPFREELIST_NODE(*freelist) = node;
    NPFREELIST_FREE(*freelist) = free;

    return NPFREELIST_FREE(*freelist);
}

void npfreelist_free(NpFreeList * freelist)
{
    ULong tablelength = NPFREELIST_ELEMENT_SIZE(*freelist) * NPFREELIST_BLOCK_SIZE(*freelist);
    NpFreeNode * node = NPFREELIST_NODE(*freelist);

    NpFreeNode * next;

    while (node)
    {
	    next = NPFREENODE_NEXT(*node);
    	free(((Byte *)node) - tablelength);
    	node = next;
    }

    NPFREELIST_NODE(*freelist) = NULL;
    NPFREELIST_FREE(*freelist) = NULL;
}
