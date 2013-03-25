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

OdHeightfieldData * heightfield_alloc()
{
    return (OdHeightfieldData *)npfreenode_alloc(OD_HEIGHTFIELDDATA_FREELIST);
}

OdHeightfieldData * heightfield_alloc_init()
{
    OdHeightfieldData * result
        = (OdHeightfieldData *)npfreenode_alloc(OD_HEIGHTFIELDDATA_FREELIST);

    memset(result, 0, sizeof(OdHeightfieldData));

    return result;
}

OdHeightfieldData * heightfield_alloc_init_with_resolution_and_size(IVector2 resolution, Vector2 size)
{
    OdHeightfieldData * result
        = (OdHeightfieldData *)npfreenode_alloc(OD_HEIGHTFIELDDATA_FREELIST);

    memset(result, 0, sizeof(OdHeightfieldData));

    result->resolution = resolution;
    result->size = size;
    result->data32f = ALLOC_ARRAY(float, resolution.x * resolution.y);

    return result;
}

OdHeightfieldData * heightfield_free(OdHeightfieldData * heightfield)
{
    SAFE_FREE(heightfield->data32f);

    return npfreenode_free(heightfield, OD_HEIGHTFIELDDATA_FREELIST);
}

void heightfield_hf_compute_min_max(OdHeightfieldData * heightfield)
{
    assert( heightfield->data32f != NULL );

    float maxSurfaceHeight = -FLT_MAX;
    float minSurfaceHeight =  FLT_MAX;

    int32_t numberOfElements = heightfield->resolution.x * heightfield->resolution.y;

    for ( int32_t i = 0; i < numberOfElements; i++ )
    {
        maxSurfaceHeight = MAX(maxSurfaceHeight, heightfield->data32f[i]);
        minSurfaceHeight = MIN(minSurfaceHeight, heightfield->data32f[i]);
    }

    heightfield->dataMin = minSurfaceHeight;
    heightfield->dataMax = maxSurfaceHeight;
}

@implementation ODHeightfieldQueue

+ (void) initialize
{
	if ( [ ODHeightfieldQueue class ] == self )
	{
        od_heightfielddata_initialise();
	}
}

- (id) init
{
    return [ self initWithName:@"ODHeightfieldQueue" ];
}

- (id) initWithName:(NSString *)newName
{
    self =  [ super initWithName:newName ];

    NSPointerFunctionsOptions options
        = NSPointerFunctionsOpaqueMemory | NSPointerFunctionsOpaquePersonality;

    queue = [[ NSPointerArray alloc ] initWithOptions:options ];

    return self;
}

- (void) dealloc
{
    [ self removeAllHeightfields ];
    [ super dealloc ];
}

- (NSUInteger) count
{
    return [ queue count ];
}

- (double) minTimeStamp
{
    double result = DBL_MAX;
    NSUInteger count = [ queue count ];

    for ( NSUInteger i = 0; i < count; i++ )
    {
        OdHeightfieldData * hf = [ queue pointerAtIndex:i ];

        if ( hf != NULL )
        {
            result = MIN(result, hf->timeStamp);
        }
    }

    return result;
}

- (double) maxTimeStamp
{
    double result = -DBL_MAX;
    NSUInteger count = [ queue count ];

    for ( NSUInteger i = 0; i < count; i++ )
    {
        OdHeightfieldData * hf = [ queue pointerAtIndex:i ];

        if ( hf != NULL )
        {
            result = MAX(result, hf->timeStamp);
        }
    }

    return result;
}

- (OdHeightfieldData *) heightfieldAtIndex:(NSUInteger)index
{
    return (OdHeightfieldData *)[ queue pointerAtIndex:index ];
}

- (void) addHeightfield:(OdHeightfieldData *)heightfield
{
    [ queue addPointer:heightfield ];
}

- (void) removeHeightfieldAtIndex:(NSUInteger)index
{
    OdHeightfieldData * hf = [ queue pointerAtIndex:index ];

    if ( hf != NULL )
    {
        heightfield_free(hf);
    }

    [ queue removePointerAtIndex:index ];
}

- (void) removeAllHeightfields
{
    NSUInteger count = [ queue count ];

    for ( NSUInteger i = 0; i < count; i++ )
    {
        OdHeightfieldData * hf = [ queue pointerAtIndex:i ];

        if ( hf != NULL )
        {
            heightfield_free(hf);
        }
    }

    [ queue removeAllPointers ];
}

- (void) removeHeightfieldsInRange:(NSRange)aRange
{
    NSUInteger numberOfPointers = [ self count ];
    NSUInteger startIndex = aRange.location;

    NSUInteger i = aRange.location + aRange.length;

    if ( numberOfPointers < i )
    {
        i = numberOfPointers;
    }

    if ( i > startIndex )
    {
        while ( i-- > startIndex )
        {
            [ self removeHeightfieldAtIndex:i ];
        }
    }
}

- (void) insertHeightfield:(OdHeightfieldData *)heightfield
                   atIndex:(NSUInteger)index
{
    [ queue insertPointer:heightfield atIndex:index ];
}

- (void) replaceHeightfieldAtIndex:(NSUInteger)index
                   withHeightfield:(OdHeightfieldData *)heightfield
{
    OdHeightfieldData * hf = [ queue pointerAtIndex:index ];

    if ( hf != NULL )
    {
        heightfield_free(hf);
    }

    [ queue replacePointerAtIndex:index withPointer:heightfield ];
}

@end
