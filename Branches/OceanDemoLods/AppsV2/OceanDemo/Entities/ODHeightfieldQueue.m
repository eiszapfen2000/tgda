#import <Foundation/NSPointerArray.h>
#import <Foundation/NSString.h>
#import "fftw3.h"
#import "Core/Basics/NpFreeList.h"
#import "Core/Container/NSPointerArray+NPEngine.h"
#import "ODHeightfieldQueue.h"

void heightfield_hf_init_with_geometry_and_options(
    OdHeightfieldData * heightfield,
    const OdHeightfieldGeometry * const geometry,
    OdGeneratorOptions options    
    )
{
    assert(heightfield != NULL && geometry != NULL);

    heightfield_hf_clear(heightfield);

    geometry_copy(geometry, &heightfield->geometry);

    const size_t numberOfLods = geometry->numberOfLods;

    const size_t numberOfGeometryElements
        = geometry->geometryResolution.x * geometry->geometryResolution.y;

    const size_t numberOfGradientElements
        = geometry->gradientResolution.x * geometry->gradientResolution.y;

    heightfield->heights32f
        = fftwf_alloc_real(numberOfLods * numberOfGeometryElements);

    heightfield->displacements32f
        = (FVector2 *)fftwf_alloc_real(numberOfLods * numberOfGeometryElements * 2);

    heightfield->displacementDerivatives32f
        = (FVector4 *)fftwf_alloc_real(numberOfLods * numberOfGradientElements * 4);

    heightfield->gradients32f
        = (FVector2 *)fftwf_alloc_real(numberOfLods * numberOfGradientElements * 2);
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
    assert( heightfield != NULL );

    if ( heightfield->heights32f == NULL )
    {
        return;
    }

    float maxSurfaceHeight = -FLT_MAX;
    float minSurfaceHeight =  FLT_MAX;

    int32_t numberOfElements
        = heightfield->geometry.geometryResolution.x * heightfield->geometry.geometryResolution.y;

    for ( int32_t i = 0; i < numberOfElements; i++ )
    {
        maxSurfaceHeight = MAX(maxSurfaceHeight, heightfield->heights32f[i]);
        minSurfaceHeight = MIN(minSurfaceHeight, heightfield->heights32f[i]);
    }

    heightfield->heightRange = (FVector2){minSurfaceHeight, maxSurfaceHeight};
}

void heightfield_hf_compute_min_max_gradients(OdHeightfieldData * heightfield)
{
    assert( heightfield != NULL );

    if ( heightfield->gradients32f == NULL )
    {
        return;
    }

    float maxGradientX = -FLT_MAX;
    float maxGradientZ = -FLT_MAX;

    float minGradientX = FLT_MAX;
    float minGradientZ = FLT_MAX;

    const int32_t numberOfElements
        = heightfield->geometry.gradientResolution.x * heightfield->geometry.gradientResolution.y;

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
    assert( heightfield != NULL );

    if ( heightfield->displacements32f == NULL )
    {
        return;
    }

    float maxDisplacementX = -FLT_MAX;
    float maxDisplacementZ = -FLT_MAX;

    float minDisplacementX = FLT_MAX;
    float minDisplacementZ = FLT_MAX;

    const int32_t numberOfElements
        = heightfield->geometry.geometryResolution.x * heightfield->geometry.geometryResolution.y;

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
    assert( heightfield != NULL );

    if ( heightfield->displacementDerivatives32f == NULL )
    {
        return;
    }

    float maxDisplacementXdX = -FLT_MAX;
    float maxDisplacementXdZ = -FLT_MAX;
    float maxDisplacementZdX = -FLT_MAX;
    float maxDisplacementZdZ = -FLT_MAX;

    float minDisplacementXdX =  FLT_MAX;
    float minDisplacementXdZ =  FLT_MAX;
    float minDisplacementZdX =  FLT_MAX;
    float minDisplacementZdZ =  FLT_MAX;

    const int32_t numberOfElements
        = heightfield->geometry.gradientResolution.x * heightfield->geometry.gradientResolution.y;

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

OdHeightfieldData heightfield_zero()
{
    OdHeightfieldData result;
    memset(&result, 0, sizeof(result));

    return result;
}

static NSUInteger heightfield_size(const void * item)
{
    return sizeof(OdHeightfieldData);
}

@implementation ODHeightfieldQueue

- (id) init
{
    return [ self initWithName:@"ODHeightfieldQueue" ];
}

- (id) initWithName:(NSString *)newName
{
    self =  [ super initWithName:newName ];

    const NSUInteger options
        = NSPointerFunctionsMallocMemory
          | NSPointerFunctionsStructPersonality
          | NSPointerFunctionsCopyIn;

    NSPointerFunctions * pFunctions
        = [ NSPointerFunctions pointerFunctionsWithOptions:options ];

    [ pFunctions setSizeFunction:&heightfield_size ];

    queue = [[ NSPointerArray alloc ] initWithPointerFunctions:pFunctions ];

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
    heightfield_hf_clear([ queue pointerAtIndex:index ]);

    [ queue removePointerAtIndex:index ];
}

- (void) removeAllHeightfields
{
    NSUInteger count = [ queue count ];

    for ( NSUInteger i = 0; i < count; i++ )
    {
        heightfield_hf_clear([ queue pointerAtIndex:i ]);
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
    heightfield_hf_clear([ queue pointerAtIndex:index ]);
    [ queue replacePointerAtIndex:index withPointer:heightfield ];
}

@end
