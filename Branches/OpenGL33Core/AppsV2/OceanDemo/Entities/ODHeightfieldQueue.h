#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "Ocean/ODPFrequencySpectrumGeneration.h"

@class NSPointerArray;

typedef OdSpectrumGeometry OdHeightfieldGeometry;

#define NUMBER_OF_FFT_TIMINGS       4
#define HEIGHTS_FFT_TIMING          (NUMBER_OF_GEN_TIMINGS + 0)
#define DISPLACEMENTS_FFT_TIMING    (NUMBER_OF_GEN_TIMINGS + 1)
#define GRADIENTS_FFT_TIMING        (NUMBER_OF_GEN_TIMINGS + 2)
#define DISP_DERIVATIVES_FFT_TIMING (NUMBER_OF_GEN_TIMINGS + 3)

#define NUMBER_OF_TIMINGS (NUMBER_OF_GEN_TIMINGS + NUMBER_OF_FFT_TIMINGS)


typedef struct OdHeightfieldData
{
    float timeStamp;
    OdHeightfieldGeometry geometry;
    float * heights32f;
    FVector2 * displacements32f; //  x = displacement x, y = displacement z
    FVector2 * gradients32f; // x = gradient x, y = gradient z
    FVector4 * displacementDerivatives32f; // x = dx_x , y = dx_z, z = dz_x, w = dz_z
    FVector2 * ranges;
    double timings[NUMBER_OF_TIMINGS];
}
OdHeightfieldData;

#define NUMBER_OF_RANGES        9

#define HEIGHT_RANGE            0
#define GRADIENT_X_RANGE        1
#define GRADIENT_Z_RANGE        2
#define DISPLACEMENT_X_RANGE    3
#define DISPLACEMENT_Z_RANGE    4
#define DISPLACEMENT_X_DX_RANGE 5
#define DISPLACEMENT_X_DZ_RANGE 6
#define DISPLACEMENT_Z_DX_RANGE 7
#define DISPLACEMENT_Z_DZ_RANGE 8


void heightfield_hf_init_with_geometry_and_options(
    OdHeightfieldData * heightfield,
    const OdSpectrumGeometry * const geometry,
    OdGeneratorOptions options    
    );

void heightfield_hf_clear(OdHeightfieldData * heightfield);
void heightfield_hf_compute_min_max(OdHeightfieldData * heightfield);
void heightfield_hf_compute_min_max_gradients(OdHeightfieldData * heightfield);
void heightfield_hf_compute_min_max_displacements(OdHeightfieldData * heightfield);
void heightfield_hf_compute_min_max_displacement_derivatives(OdHeightfieldData * heightfield);

OdHeightfieldData heightfield_zero();

@interface ODHeightfieldQueue : NPObject
{
    NSPointerArray * queue;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (NSUInteger) count;
- (OdHeightfieldData *) heightfieldAtIndex:(NSUInteger)index;
- (void) addHeightfield:(OdHeightfieldData *)heightfield;
- (void) removeHeightfieldAtIndex:(NSUInteger)index;
- (void) removeHeightfieldsInRange:(NSRange)aRange;
- (void) removeAllHeightfields;
- (void) insertHeightfield:(OdHeightfieldData *)heightfield atIndex:(NSUInteger)index;
- (void) replaceHeightfieldAtIndex:(NSUInteger)index withHeightfield:(OdHeightfieldData *)heightfield;

@end

