#include "NpFreeList.h"

NpFreeNode* npfreelist_alloc_block( NpFreeList * freelist )
{
    size_t tablelength = NPFREELIST_ELEMENT_SIZE(*freelist) * NPFREELIST_BLOCK_SIZE(*freelist);

    NpFreeNode * node = malloc(tablelength + sizeof(NpFreeNode));
    NpFreeNode * free = NULL;
    
    for (size_t i = 0; i < NPFREELIST_BLOCK_SIZE(*freelist); i++)
    {
	    NPFREENODE_NEXT(*node) = free;
	    free = node;

        // cast to uint8_t* so that we can count bytewise
	    node = (NpFreeNode*)(((uint8_t *)node) + NPFREELIST_ELEMENT_SIZE(*freelist));
    }

    NPFREENODE_NEXT(*node) = NPFREELIST_NODE(*freelist);
    NPFREELIST_NODE(*freelist) = node;
    NPFREELIST_FREE(*freelist) = free;

    return NPFREELIST_FREE(*freelist);
}

void npfreelist_free( NpFreeList * freelist )
{
    size_t tablelength = NPFREELIST_ELEMENT_SIZE(*freelist) * NPFREELIST_BLOCK_SIZE(*freelist);
    NpFreeNode * node = NPFREELIST_NODE(*freelist);

    NpFreeNode * next;

    while (node)
    {
	    next = NPFREENODE_NEXT(*node);
    	free(((uint8_t *)node) - tablelength);
    	node = next;
    }

    NPFREELIST_NODE(*freelist) = NULL;
    NPFREELIST_FREE(*freelist) = NULL;
}

void* npfreenode_alloc( NpFreeList * freelist )
{
    NpFreeNode * free = NPFREELIST_FREE(*freelist);

    if ( free == NULL )
    {
        free = npfreelist_alloc_block(freelist);
    }

    NPFREELIST_FREE(*freelist) = NPFREENODE_NEXT(*free);
    NPFREELIST_INC_ALLOCATED(freelist);

    return (void *)free;
}

void* npfreenode_fast_free( void * node, NpFreeList * freelist )
{
    NPFREELIST_DEC_ALLOCATED(freelist);

    NPFREENODE_NEXT(*((NpFreeNode *)node)) = NPFREELIST_FREE(*freelist);
    NPFREELIST_FREE(*freelist) = (NpFreeNode*)node;

    return NULL;
}

void* npfreenode_free( void * node, NpFreeList * freelist )
{
    void * result = NULL;

    if ( node != NULL && freelist != NULL )
    {
        result = npfreenode_fast_free(node, freelist);
    }

    return result;
}

