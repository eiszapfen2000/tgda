#import "NPTimer.h"

@implementation NPTimer

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    frameTime = 0.0;
    totalElapsedTime = 0.0;
    secondsPassed = 0;
    fps = 0;
    fpsThisSecond = 0;
    paused = NO;

   	gettimeofday(&lastUpdate,0);

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

- (Double) frameTime
{
    return frameTime;
}

- (Double) reciprocalFrameTime
{
    return 1.0 / frameTime;
}

- (Double) totalElapsedTime
{
    return totalElapsedTime;
}

- (void) update
{
    if ( paused == NO )
    {
        struct timeval updateTime;
        gettimeofday(&updateTime, 0);

        Double lastUpdateInSeconds = (Double)lastUpdate.tv_sec + (Double)lastUpdate.tv_usec / (1000000.0);
        Double updateTimeInSeconds = (Double)updateTime.tv_sec + (Double)updateTime.tv_usec / (1000000.0);
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
