#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "Ocean/ODPFrequencySpectrumGeneration.h"
#import "ODPEntity.h"
#import "fftw3.h"

@class NSCondition;
@class NSLock;
@class NSPointerArray;
@class NSThread;
@class NPEffect;
@class NPTimer;
@class NPTexture2D;
@class NPStateSet;
@class ODCamera;
@class ODProjector;
@class ODBasePlane;

#define ODOCEANENTITY_NUMBER_OF_RESOLUTIONS     4

@interface ODOceanEntity : NPObject < ODPEntity >
{
    NSCondition * condition;
    NSLock * mutex;

    Vector2 lastWindDirection;
    Vector2 windDirection;
    NSUInteger lastResolutionIndex;
    NSUInteger resolutionIndex;

    ODSpectrumSettings spectrumSettings;
    BOOL generateData;

    fftwf_plan plans[ODOCEANENTITY_NUMBER_OF_RESOLUTIONS];
    
    NSThread * thread;
    NSPointerArray * resultQueue;

    ODProjector * projector;
    ODBasePlane * basePlane;

    NPStateSet * stateset;
    NPEffect * effect;
    NPTexture2D * heightfield;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (void) start;
- (void) stop;

- (ODProjector *) projector;
- (ODBasePlane *) basePlane;

- (void) setCamera:(ODCamera *)newCamera;

@end

