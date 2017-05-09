#import "NPTimer.h"

@implementation NPTimer

- (id) init
{
    return [ self initWithName:@"Timer" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    frameTime = 0.0;
    totalElapsedTime = 0.0;
    secondsPassed = 0;
    fps = 0;
    fpsThisSecond = 0;
    paused = NO;
    clock_gettime(CLOCK_MONOTONIC, &lastUpdate);

    return self;
}

- (void) setup
{
    [ self reset ];
}

- (int32_t) fps
{
    return fps;
}

- (double) frameTime
{
    return frameTime;
}

- (double) reciprocalFrameTime
{
    return 1.0 / frameTime;
}

- (double) totalElapsedTime
{
    return totalElapsedTime;
}

- (void) update
{
    if ( paused == NO )
    {
        struct timespec updateTime;
        clock_gettime(CLOCK_MONOTONIC, &updateTime);

        // compute difference using same types
        // convert to double afterwards

        struct timespec diff;

        if ( (updateTime.tv_nsec - lastUpdate.tv_nsec) < 0 )
        {
            diff.tv_sec  = updateTime.tv_sec - lastUpdate.tv_sec - 1;
            diff.tv_nsec = 1000000000 + updateTime.tv_nsec - lastUpdate.tv_nsec;
        }
        else
        {
            diff.tv_sec  = updateTime.tv_sec  - lastUpdate.tv_sec;
            diff.tv_nsec = updateTime.tv_nsec - lastUpdate.tv_nsec;
        }

        frameTime = ((double)(diff.tv_sec)) + ((double)(diff.tv_nsec) / 1000000000.0);
        lastUpdate = updateTime;

        totalElapsedTime += frameTime;

        fpsThisSecond++;

        int64_t totalSeconds = (int64_t)totalElapsedTime;

        if ( totalSeconds != secondsPassed )
        {
            fps = fpsThisSecond;
            fpsThisSecond = 0;
            secondsPassed = totalSeconds;
        }
    }   
}

- (void) resetFrameTime
{
    frameTime = 0.0;
    clock_gettime(CLOCK_MONOTONIC, &lastUpdate);
}

- (void) resetTotalElapsedTime
{
    totalElapsedTime = 0.0;
}

- (void) reset
{
    frameTime = 0.0;
    totalElapsedTime = 0.0;
    secondsPassed = 0;
    fps = 0;
    fpsThisSecond = 0;
    clock_gettime(CLOCK_MONOTONIC, &lastUpdate);
}

- (void) pause
{
    paused = YES;
}

- (BOOL) isTimerPaused
{
    return paused;
}

@end
