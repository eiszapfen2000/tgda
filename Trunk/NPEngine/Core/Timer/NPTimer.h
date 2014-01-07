#import <sys/time.h>
#import "Core/NPObject/NPObject.h"

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
- (id) initWithName:(NSString *) newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;

- (Int) fps;
- (Double) frameTime;
- (Double) reciprocalFrameTime;
- (Double) totalElapsedTime;

- (void) setup;

- (void) update;
- (void) resetFrameTime;
- (void) resetTotalElapsedTime;
- (void) reset;
- (void) pause;
- (BOOL) isTimerPaused;

@end
