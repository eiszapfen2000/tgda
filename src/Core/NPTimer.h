#import "NPObject.h"

#import <sys/time.h>

@interface NPTimer : NPObject
{
    struct timeval lastUpdate;
    Double  frameTime;
    Double  totalElapsedTime;
    Int64   secondsPassed;
    Int     fps;
    Int     fpsThisSecond;
}

- (id) init;
- (id) initWithName: (NSString *) newName;

- (Double) frameTime;
- (Double) totalElapsedTime;

- (void) updateTimer;

@end
