#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "Ocean/ODPFrequencySpectrumGeneration.h"
#import "ODPEntity.h"

@class NSPointerArray;
@class NSThread;
@class NPEffect;
@class NPTimer;
@class NPTexture2D;
@class NPStateSet;
@class ODCamera;
@class ODProjector;
@class ODBasePlane;

@interface ODOceanEntity : NPObject < ODPEntity >
{
    Vector2 lastWindDirection;
    Vector2 windDirection;
    NSUInteger lastResolutionIndex;
    NSUInteger resolutionIndex;

    ODSpectrumSettings spectrumSettings;
    
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

