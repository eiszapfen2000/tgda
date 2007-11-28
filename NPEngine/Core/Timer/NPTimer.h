#import "Core/NPObject/NPObject.h"
#import "Core/NPObject/NPPCoreProtocols.h"

#import <sys/time.h>

@interface NPTimer : NPObject < NPPInitialStateSetup > 
{
    struct timeval lastUpdate;
    Double  frameTime;
    Double  totalElapsedTime;
    Int64   secondsPassed;
    Int     fps;
    Int     fpsThisSecond;
    BOOL    paused;
}

- (id) init;
- (id) initWithName: (NSString *) newName;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;

- (Double) frameTime;
- (Double) totalElapsedTime;

- (void) updateTimer;
- (void) resetFrameTime;
- (void) resetTotalElapsedTime;
- (void) reset;
- (void) pause;
- (BOOL) isTimerPaused;

@end
