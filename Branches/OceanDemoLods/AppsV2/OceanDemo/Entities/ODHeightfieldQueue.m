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

    const size_t numberOfGeometryElements
        = geometryResolution.x * geometryResolution.y;

    const size_t numberOfGradientElements
        = gradientResolution.x * gradientResolution.y;

    result->geometryResolution = geometryResolution;
    result->gradientResolution = gradientResolution;
    result->size = size;

    result->heights32f
        = fftwf_alloc_real(numberOfGeometryElements);

    result->displacements32f
        = (FVector2 *)fftwf_alloc_real(numberOfGeometryElements * 2);

    result->displacementDerivatives32f
        = (FVector4 *)fftwf_alloc_real(numberOfGradientElements * 4);

    result->gradients32f
        = (FVector2 *)fftwf_alloc_real(numberOfGradientElements * 2);

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

void heightfield_hf_init_with_resolutions_and_size(
    OdHeightfieldData * heightfield,
    IVector2 geometryResolution,
    IVector2 gradientResolution,
    Vector2 size
    )
{
    memset(heightfield, 0, sizeof(OdHeightfieldData));

    const size_t numberOfGeometryElements
        = geometryResolution.x * geometryResolution.y;

    const size_t numberOfGradientElements
        = gradientResolution.x * gradientResolution.y;

    heightfield->geometryResolution = geometryResolution;
    heightfield->gradientResolution = gradientResolution;
    heightfield->size = size;

    heightfield->heights32f
        = fftwf_alloc_real(numberOfGeometryElements);

    heightfield->displacements32f
        = (FVector2 *)fftwf_alloc_real(numberOfGeometryElements * 2);

    heightfield->displacementDerivatives32f
        = (FVector4 *)fftwf_alloc_real(numberOfGradientElements * 4);

    heightfield->gradients32f
        = (FVector2 *)fftwf_alloc_real(numberOfGradientElements * 2);
}

void heightfield_hf_clear(OdHeightfieldData * heightfield)
{
    if ( heightfield != NULL )
    {
        fftwf_free(heightfield->heights32f);
        fftwf_free(heightfield->displacements32f);
        fftwf_free(heightfield->displacementDerivatives32f);
        fftwf_free(heightfield->gradients32f);
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

    heightfield->heightRange = (FVector2){minSurfaceHeight, maxSurfaceHeight};
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

    heightfield->gradientXRange = (FVector2){minGradientX, maxGradientX};
    heightfield->gradientZRange = (FVector2){minGradientZ, maxGradientZ};
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

    heightfield->displacementXRange = (FVector2){minDisplacementX, maxDisplacementX};
    heightfield->displacementZRange = (FVector2){minDisplacementZ, maxDisplacementZ};
}

void heightfield_hf_compute_min_max_displacement_derivatives(OdHeightfieldData * heightfield)
{
    assert( heightfield->displacementDerivatives32f != NULL );

    float maxDisplacementXdX = -FLT_MAX;
    float maxDisplacementXdZ = -FLT_MAX;
    float maxDisplacementZdX = -FLT_MAX;
    float maxDisplacementZdZ = -FLT_MAX;

    float minDisplacementXdX =  FLT_MAX;
    float minDisplacementXdZ =  FLT_MAX;
    float minDisplacementZdX =  FLT_MAX;
    float minDisplacementZdZ =  FLT_MAX;

    const int32_t numberOfElements
        = heightfield->gradientResolution.x * heightfield->gradientResolution.y;

    for ( int32_t i = 0; i < numberOfElements; i++ )
    {
        maxDisplacementXdX = MAX(maxDisplacementXdX, heightfield->displacementDerivatives32f[i].x);
        maxDisplacementXdZ = MAX(maxDisplacementXdZ, heightfield->displacementDerivatives32f[i].y);
        maxDisplacementZdX = MAX(maxDisplacementZdX, heightfield->displacementDerivatives32f[i].z);
        maxDisplacementZdZ = MAX(maxDisplacementZdZ, heightfield->displacementDerivatives32f[i].w);

        minDisplacementXdX = MIN(minDisplacementXdX, heightfield->displacementDerivatives32f[i].x);
        minDisplacementXdZ = MIN(minDisplacementXdZ, heightfield->displacementDerivatives32f[i].y);
        minDisplacementZdX = MIN(minDisplacementZdX, heightfield->displacementDerivatives32f[i].z);
        minDisplacementZdZ = MIN(minDisplacementZdZ, heightfield->displacementDerivatives32f[i].w);
    }

    heightfield->displacementXdXRange = (FVector2){minDisplacementXdX, maxDisplacementXdX};
    heightfield->displacementXdZRange = (FVector2){minDisplacementXdZ, maxDisplacementXdZ};
    heightfield->displacementZdXRange = (FVector2){minDisplacementZdX, maxDisplacementZdX};
    heightfield->displacementZdZRange = (FVector2){minDisplacementZdZ, maxDisplacementZdZ};
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
    DESTROY(queue);

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
