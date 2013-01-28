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

OdHeightfieldData * hf_alloc();
OdHeightfieldData * hf_alloc_init();
OdHeightfieldData * hf_free(OdHeightfieldData * heightfield);

@interface ODHeightfieldQueue : NPObject
{
    NSPointerArray * queue;
}
@end
