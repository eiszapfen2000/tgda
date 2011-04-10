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

   	gettimeofday(&lastUpdate, 0);

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
        struct timeval updateTime;
        gettimeofday(&updateTime, 0);

        double lastUpdateInSeconds = ((double)lastUpdate.tv_sec) + (((double)lastUpdate.tv_usec) / (1000000.0));
        double updateTimeInSeconds = ((double)updateTime.tv_sec) + (((double)updateTime.tv_usec) / (1000000.0));
        frameTime  = updateTimeInSeconds - lastUpdateInSeconds;
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
    gettimeofday(&lastUpdate, 0);
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

   	gettimeofday(&lastUpdate, 0);
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
