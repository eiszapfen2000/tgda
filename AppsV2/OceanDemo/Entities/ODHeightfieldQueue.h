#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"

@class NSPointerArray;

typedef struct OdHeightfieldData
{
    IVector2 resolution;
    Vector2 size;
    double timeStamp;
    float * heights32f;
    float * gradientX;
    float * gradientZ;
    float * displacementX;
    float * displacementZ;
    float minHeight;
    float maxHeight;
    float minGradientX;
    float maxGradientX;
    float minGradientZ;
    float maxGradientZ;
    float minDisplacementX;
    float maxDisplacementX;
    float minDisplacementZ;
    float maxDisplacementZ;
}
OdHeightfieldData;

void od_heightfielddata_initialise();

OdHeightfieldData * heightfield_alloc();
OdHeightfieldData * heightfield_alloc_init();
OdHeightfieldData * heightfield_alloc_init_with_resolution_and_size(IVector2 resolution, Vector2 size);
void heightfield_free(OdHeightfieldData * heightfield);
void heightfield_hf_compute_min_max(OdHeightfieldData * heightfield);
void heightfield_hf_compute_min_max_gradients(OdHeightfieldData * heightfield);
void heightfield_hf_compute_min_max_displacements(OdHeightfieldData * heightfield);

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

