#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "ODPEntity.h"

@class NSThread;
@class NPTimer;
@class NPStateSet;
@class ODCamera;
@class ODProjector;
@class ODProjectedGrid;

@interface ODOceanEntity : NPObject < ODPEntity >
{
    NSThread * thread;

    ODProjector * projector;
    ODProjectedGrid * projectedGrid;

    NPStateSet * stateset;
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

