#import <sys/time.h>
#import "Core/NPObject/NPObject.h"

@interface NPTimer : NPObject
{
    struct timeval lastUpdate;
    double frameTime;
    double totalElapsedTime;
    int64_t secondsPassed;
    int32_t fps;
    int32_t fpsThisSecond;
    BOOL paused;
}

- (id) init;
- (id) initWithName:(NSString *) newName;

- (int32_t) fps;
- (double) frameTime;
- (double) reciprocalFrameTime;
- (double) totalElapsedTime;

- (void) setup;

- (void) update;
- (void) resetFrameTime;
- (void) resetTotalElapsedTime;
- (void) reset;
- (void) pause;
- (BOOL) isTimerPaused;

@end
