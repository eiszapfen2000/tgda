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
@class ODProjectedGrid;

@interface ODOceanEntity : NPObject < ODPEntity >
{
    Vector2 lastWindDirection;
    Vector2 windDirection;

    ODSpectrumSettings spectrumSettings;
    
    NSThread * thread;
    NSPointerArray * resultQueue;

    ODProjector * projector;
    ODProjectedGrid * projectedGrid;

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
- (ODProjectedGrid *) projectedGrid;

- (void) setCamera:(ODCamera *)newCamera;

@end

