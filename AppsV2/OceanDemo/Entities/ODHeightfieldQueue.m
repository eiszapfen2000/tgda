#import <Foundation/NSPointerArray.h>
#import <Foundation/NSString.h>
#import "fftw3.h"
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
    result->heights32f = fftwf_alloc_real(resolution.x * resolution.y);
    result->supplementalData32f = (FVector4 *)fftwf_alloc_real(resolution.x * resolution.y * 4);

    return result;
}

void heightfield_free(OdHeightfieldData * heightfield)
{
    if ( heightfield != NULL )
    {
        fftwf_free(heightfield->heights32f);
        fftwf_free(heightfield->supplementalData32f);

        npfreenode_free(heightfield, OD_HEIGHTFIELDDATA_FREELIST);
    }
}

void heightfield_hf_compute_min_max(OdHeightfieldData * heightfield)
{
    assert( heightfield->heights32f != NULL );

    float maxSurfaceHeight = -FLT_MAX;
    float minSurfaceHeight =  FLT_MAX;

    int32_t numberOfElements = heightfield->resolution.x * heightfield->resolution.y;

    for ( int32_t i = 0; i < numberOfElements; i++ )
    {
        maxSurfaceHeight = MAX(maxSurfaceHeight, heightfield->heights32f[i]);
        minSurfaceHeight = MIN(minSurfaceHeight, heightfield->heights32f[i]);
    }

    heightfield->minHeight = minSurfaceHeight;
    heightfield->maxHeight = maxSurfaceHeight;
}

void heightfield_hf_compute_min_max_gradients(OdHeightfieldData * heightfield)
{
    assert( heightfield->supplementalData32f != NULL );

    float maxGradientX = -FLT_MAX;
    float maxGradientZ = -FLT_MAX;

    float minGradientX = FLT_MAX;
    float minGradientZ = FLT_MAX;

    const int32_t numberOfElements
        = heightfield->resolution.x * heightfield->resolution.y;

    for ( int32_t i = 0; i < numberOfElements; i++ )
    {
        maxGradientX = MAX(maxGradientX, heightfield->supplementalData32f[i].x);
        maxGradientZ = MAX(maxGradientZ, heightfield->supplementalData32f[i].y);

        minGradientX = MIN(minGradientX, heightfield->supplementalData32f[i].x);
        minGradientZ = MIN(minGradientZ, heightfield->supplementalData32f[i].y);
    }

    heightfield->minGradientX = minGradientX;
    heightfield->minGradientZ = minGradientZ;
    heightfield->maxGradientX = maxGradientX;
    heightfield->maxGradientZ = maxGradientZ;
}

void heightfield_hf_compute_min_max_displacements(OdHeightfieldData * heightfield)
{
    assert( heightfield->supplementalData32f != NULL );

    float maxDisplacementX = -FLT_MAX;
    float maxDisplacementZ = -FLT_MAX;

    float minDisplacementX = FLT_MAX;
    float minDisplacementZ = FLT_MAX;

    const int32_t numberOfElements
        = heightfield->resolution.x * heightfield->resolution.y;

    for ( int32_t i = 0; i < numberOfElements; i++ )
    {
        maxDisplacementX = MAX(maxDisplacementX, heightfield->supplementalData32f[i].z);
        maxDisplacementZ = MAX(maxDisplacementZ, heightfield->supplementalData32f[i].w);

        minDisplacementX = MIN(minDisplacementX, heightfield->supplementalData32f[i].z);
        minDisplacementZ = MIN(minDisplacementZ, heightfield->supplementalData32f[i].w);
    }

    heightfield->minDisplacementX = minDisplacementX;
    heightfield->minDisplacementZ = minDisplacementZ;
    heightfield->maxDisplacementX = maxDisplacementX;
    heightfield->maxDisplacementZ = maxDisplacementZ;
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
    heightfield_free([ queue pointerAtIndex:index ]);

    [ queue removePointerAtIndex:index ];
}

- (void) removeAllHeightfields
{
    NSUInteger count = [ queue count ];

    for ( NSUInteger i = 0; i < count; i++ )
    {
        heightfield_free([ queue pointerAtIndex:i ]);
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
    heightfield_free([ queue pointerAtIndex:index ]);
    [ queue replacePointerAtIndex:index withPointer:heightfield ];
}

@end
