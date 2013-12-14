#import <Foundation/NSPointerArray.h>
#import <Foundation/NSString.h>
#import "fftw3.h"
#import "Core/Basics/NpFreeList.h"
#import "Core/Container/NSPointerArray+NPEngine.h"
#import "ODHeightfieldQueue.h"

static NpFreeList * OD_HEIGHTFIELDDATA_FREELIST = NULL;

void od_heightfielddata_initialise(void)
{
    NPFREELIST_ALLOC_INIT(OD_HEIGHTFIELDDATA_FREELIST, OdHeightfieldData, 128)
}

OdHeightfieldData * heightfield_alloc(void)
{
    return (OdHeightfieldData *)npfreenode_alloc(OD_HEIGHTFIELDDATA_FREELIST);
}

OdHeightfieldData * heightfield_alloc_init(void)
{
    OdHeightfieldData * result
        = (OdHeightfieldData *)npfreenode_alloc(OD_HEIGHTFIELDDATA_FREELIST);

    memset(result, 0, sizeof(OdHeightfieldData));

    return result;
}

OdHeightfieldData * heightfield_alloc_init_with_resolutions_and_size(
    IVector2 geometryResolution, IVector2 gradientResolution,
    Vector2 size)
{
    OdHeightfieldData * result
        = (OdHeightfieldData *)npfreenode_alloc(OD_HEIGHTFIELDDATA_FREELIST);

    memset(result, 0, sizeof(OdHeightfieldData));

    result->geometryResolution = geometryResolution;
    result->gradientResolution = gradientResolution;
    result->size = size;
    result->heights32f = fftwf_alloc_real(geometryResolution.x * geometryResolution.y);
    result->displacements32f = (FVector2 *)fftwf_alloc_real(geometryResolution.x * geometryResolution.y * 2);
    result->displacementDerivatives32f = (FVector4 *)fftwf_alloc_real(geometryResolution.x * geometryResolution.y * 4);
    result->gradients32f = (FVector2 *)fftwf_alloc_real(gradientResolution.x * gradientResolution.y * 2);

    return result;
}

void heightfield_free(OdHeightfieldData * heightfield)
{
    if ( heightfield != NULL )
    {
        fftwf_free(heightfield->heights32f);
        fftwf_free(heightfield->displacements32f);
        fftwf_free(heightfield->displacementDerivatives32f);
        fftwf_free(heightfield->gradients32f);

        npfreenode_free(heightfield, OD_HEIGHTFIELDDATA_FREELIST);
    }
}

void heightfield_hf_compute_min_max(OdHeightfieldData * heightfield)
{
    assert( heightfield->heights32f != NULL );

    float maxSurfaceHeight = -FLT_MAX;
    float minSurfaceHeight =  FLT_MAX;

    int32_t numberOfElements
        = heightfield->geometryResolution.x * heightfield->geometryResolution.y;

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
    assert( heightfield->gradients32f != NULL );

    float maxGradientX = -FLT_MAX;
    float maxGradientZ = -FLT_MAX;

    float minGradientX = FLT_MAX;
    float minGradientZ = FLT_MAX;

    const int32_t numberOfElements
        = heightfield->gradientResolution.x * heightfield->gradientResolution.y;

    for ( int32_t i = 0; i < numberOfElements; i++ )
    {
        maxGradientX = MAX(maxGradientX, heightfield->gradients32f[i].x);
        maxGradientZ = MAX(maxGradientZ, heightfield->gradients32f[i].y);

        minGradientX = MIN(minGradientX, heightfield->gradients32f[i].x);
        minGradientZ = MIN(minGradientZ, heightfield->gradients32f[i].y);
    }

    heightfield->minGradientX = minGradientX;
    heightfield->minGradientZ = minGradientZ;
    heightfield->maxGradientX = maxGradientX;
    heightfield->maxGradientZ = maxGradientZ;
}

void heightfield_hf_compute_min_max_displacements(OdHeightfieldData * heightfield)
{
    assert( heightfield->displacements32f != NULL );

    float maxDisplacementX = -FLT_MAX;
    float maxDisplacementZ = -FLT_MAX;

    float minDisplacementX = FLT_MAX;
    float minDisplacementZ = FLT_MAX;

    const int32_t numberOfElements
        = heightfield->geometryResolution.x * heightfield->geometryResolution.y;

    for ( int32_t i = 0; i < numberOfElements; i++ )
    {
        maxDisplacementX = MAX(maxDisplacementX, heightfield->displacements32f[i].x);
        maxDisplacementZ = MAX(maxDisplacementZ, heightfield->displacements32f[i].y);

        minDisplacementX = MIN(minDisplacementX, heightfield->displacements32f[i].x);
        minDisplacementZ = MIN(minDisplacementZ, heightfield->displacements32f[i].y);
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
