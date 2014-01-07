#define _GNU_SOURCE
#include <stdio.h>
#include "IBBox.h"

#ifndef MIN
#define MIN(_a,_b) ((_a < _b )? _a:_b)
#endif

#ifndef MAX
#define MAX(_a,_b) ((_a > _b )? _a:_b)
#endif

NpFreeList * NP_IBBOX_FREELIST = NULL;

void npmath_ibbox_initialise(void)
{
    NPFREELIST_ALLOC_INIT(NP_IBBOX_FREELIST, IBBox, 512);
}

IBBox * ibbox_alloc(void)
{
    return npfreenode_alloc(NP_IBBOX_FREELIST);
}

IBBox * ibbox_alloc_init(void)
{
    IBBox * bbox = npfreenode_alloc(NP_IBBOX_FREELIST);

    bbox->min.x = bbox->min.y = bbox->min.z = 0;
    bbox->max.x = bbox->max.y = bbox->max.z = 0;

    return bbox;
}

void ibbox_free(IBBox * bbox)
{
    npfreenode_free(bbox, NP_IBBOX_FREELIST);
}

