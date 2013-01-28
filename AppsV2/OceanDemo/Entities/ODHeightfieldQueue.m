#import <Foundation/NSPointerArray.h>
#import <Foundation/NSString.h>
#import "Core/Basics/NpFreeList.h"
#import "Core/Container/NSPointerArray+NPEngine.h"
#import "ODHeightfieldQueue.h"

static NpFreeList * OD_HEIGHTFIELDDATA_FREELIST = NULL;

void od_heightfielddata_initialise()
{
    NPFREELIST_ALLOC_INIT(OD_HEIGHTFIELDDATA_FREELIST, OdHeightfieldData, 128)
}

OdHeightfieldData * hf_alloc()
{
    return (OdHeightfieldData *)npfreenode_alloc(OD_HEIGHTFIELDDATA_FREELIST);
}

OdHeightfieldData * hf_alloc_init()
{
    OdHeightfieldData * result = (OdHeightfieldData *)npfreenode_alloc(OD_HEIGHTFIELDDATA_FREELIST);
    memset(result, 0, sizeof(OdHeightfieldData));

    return result;
}

OdHeightfieldData * hf_free(OdHeightfieldData * heightfield)
{
    return npfreenode_free(heightfield, OD_HEIGHTFIELDDATA_FREELIST);
}

@implementation ODHeightfieldQueue

+ (void) initialize
{
	if ( [ ODHeightfieldQueue class ] == self )
	{
        od_heightfielddata_initialise();
	}
}

@end
