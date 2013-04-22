#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "Ocean/ODPFrequencySpectrumGeneration.h"
#import "ODPEntity.h"
#import "fftw3.h"

@class NSCondition;
@class NSLock;
@class NSMutableArray;
@class NSPointerArray;
@class NSThread;
@class NPTimer;
@class NPTexture2D;
@class ODCamera;
@class ODProjector;
@class ODBasePlane;
@class ODHeightfieldQueue;

#define ODOCEANENTITY_NUMBER_OF_RESOLUTIONS     4

@interface ODOceanEntity : NPObject
{
    NSCondition * condition;
    NSLock * resultQueueMutex;

    Vector2 lastWindDirection;
    Vector2 windDirection;
    NSUInteger lastResolutionIndex;
    NSUInteger resolutionIndex;

    ODSpectrumSettings spectrumSettings;
    BOOL generateData;

    fftwf_plan complexPlans[ODOCEANENTITY_NUMBER_OF_RESOLUTIONS];
    fftwf_plan halfComplexPlans[ODOCEANENTITY_NUMBER_OF_RESOLUTIONS];
    
    NSThread * thread;
    ODHeightfieldQueue * resultQueue;

    ODProjector * projector;
    ODBasePlane * basePlane;

    NPTexture2D * heightfield;
    float minHeight;
    float maxHeight;
    double timeStamp;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (void) start;
- (void) stop;

- (ODProjector *) projector;
- (ODBasePlane *) basePlane;
- (NPTexture2D *) heightfield;
- (float) minHeight;
- (float) maxHeight; 
- (void) setCamera:(ODCamera *)newCamera;

- (void) update:(const double)frameTime;
- (void) renderBasePlane;

@end

