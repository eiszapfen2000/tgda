#import "NPTimer.h"

@implementation NPTimer

- (id) init
{
    return [ self initWithName: @"NPCore Timer" ];
}

- (id) initWithName: (NSString *) newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    frameTime = 0.0;
    totalElapsedTime = 0.0;
    secondsPassed = 0;
    fps = 0;
    fpsThisSecond = 0;
    paused = NO;

   	gettimeofday(&lastUpdate,0);

    return self;
}

- (void) setupInitialState
{
    [ self reset ];
}

- (Double) frameTime
{
    return frameTime;
}

- (Double) totalElapsedTime
{
    return totalElapsedTime;
}

- (void) updateTimer
{
    if ( paused == NO )
    {
        struct timeval updateTime;
        gettimeofday(&updateTime,0);

        Double lastUpdateInSeconds = (Double)lastUpdate.tv_sec + (Double)lastUpdate.tv_usec / (1000000);
        Double updateTimeInSeconds = (Double)updateTime.tv_sec + (Double)updateTime.tv_usec / (1000000);
        frameTime = updateTimeInSeconds - lastUpdateInSeconds;
        lastUpdate = updateTime;

        totalElapsedTime += frameTime;

        fpsThisSecond++;

        Int64 totalSeconds = (Int64)totalElapsedTime;

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
    gettimeofday(&lastUpdate,0);
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

   	gettimeofday(&lastUpdate,0);
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
