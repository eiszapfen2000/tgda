#import "Core/NPObject/NPObject.h"

#import <sys/time.h>

@interface NPTimer : NPObject
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

- (void) setup;

- (void) updateTimer;
- (void) resetFrameTime;
- (void) resetTotalElapsedTime;
- (void) reset;
- (void) pause;
- (BOOL) isTimerPaused;

@end
