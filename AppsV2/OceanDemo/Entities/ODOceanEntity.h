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
    NSCondition * generateCondition;
    NSCondition * transformCondition;
    NSLock * spectrumQueueMutex;
    NSLock * heightfieldQueueMutex;
    NSLock * settingsMutex;

    Vector2 lastWindDirection;
    Vector2 windDirection;
    Vector2 generatorWindDirection;
    NSUInteger lastResolutionIndex;
    NSUInteger resolutionIndex;
    NSUInteger generatorResolutionIndex;

    ODSpectrumSettings spectrumSettings;
    BOOL generateData;
    BOOL transformData;

    fftwf_plan complexPlans[ODOCEANENTITY_NUMBER_OF_RESOLUTIONS];
    fftwf_plan halfComplexPlans[ODOCEANENTITY_NUMBER_OF_RESOLUTIONS];
    
    NSThread * generatorThread;
    NSThread * transformThread;
    NSPointerArray * spectrumQueue;
    ODHeightfieldQueue * resultQueue;

    ODProjector * projector;
    ODBasePlane * basePlane;

    NPTexture2D * heightfield;
    NPTexture2D * gradientX;
    NPTexture2D * gradientZ;
    double timeStamp;
    FVector2 heightRange;
    FVector2 gradientXRange;
    FVector2 gradientZRange;
    BOOL animated;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (void) start;
- (void) stop;

- (ODProjector *) projector;
- (ODBasePlane *) basePlane;
- (NPTexture2D *) heightfield;
- (NPTexture2D *) gradientX;
- (NPTexture2D *) gradientZ;
- (FVector2) heightRange;
- (void) setCamera:(ODCamera *)newCamera;

- (void) update:(const double)frameTime;
- (void) renderBasePlane;

@end

