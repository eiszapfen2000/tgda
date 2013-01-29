#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "fftw3.h"

@class NSPointerArray;

typedef struct
{
    IVector2 resolution;
    Vector2 size;
    double timeStamp;
    float * data32f;
    float dataMin;
    float dataMax;
}
OdHeightfieldData;

void od_heightfielddata_initialise();

OdHeightfieldData * heightfield_alloc();
OdHeightfieldData * heightfield_alloc_init();
OdHeightfieldData * heightfield_alloc_init_with_resolution_and_size(IVector2 resolution, Vector2 size);
OdHeightfieldData * heightfield_free(OdHeightfieldData * heightfield);
void heightfield_hf_compute_min_max(OdHeightfieldData * heightfield);

@interface ODHeightfieldQueue : NPObject
{
    NSPointerArray * queue;
}
@end
