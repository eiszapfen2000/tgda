#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSThread.h>
#import "Core/Timer/NPTimer.h"
#import "Core/Thread/NPSemaphore.h"
#import "ODProjector.h"
#import "ODProjectedGrid.h"
#import "ODOceanEntity.h"

static NPSemaphore * semaphore = nil;

@interface ODOceanEntity (Private)

- (void) generate:(id)argument;

@end

@implementation ODOceanEntity (Private)

- (void) generate:(id)argument
{
    NSAutoreleasePool * pool = [ NSAutoreleasePool new ];

    while ( [[ NSThread currentThread ] isCancelled ] == NO )
    {    
        [ semaphore wait ];

        NSAutoreleasePool * innerPool = [ NSAutoreleasePool new ];

        if ( [[ NSThread currentThread ] isCancelled ] == NO )
        {
            NSLog(@"BLOB");
        }

        DESTROY(innerPool);
    }    

    DESTROY(pool);
}

@end

@implementation ODOceanEntity

+ (void) initialize
{
    semaphore = [[ NPSemaphore alloc ] init ];
}

- (id) init
{
    return [ self initWithName:@"ODOceanEntity" ];
}

- (id) initWithName:(NSString *)newName
{
    self =  [ super initWithName:newName ];

    timer = [[ NPTimer alloc ] initWithName:@"Thread Timer" ];
    projector = [[ ODProjector alloc ] initWithName:@"Projector" ];
    projectedGrid = [[ ODProjectedGrid alloc ] initWithName:@"Projected Grid" ];
    [ projectedGrid setProjector:projector ];

    return self;
}

- (void) dealloc
{
    SAFE_DESTROY(stateset);

    DESTROY(timer);
    DESTROY(projector);
    DESTROY(projectedGrid);

    [ super dealloc ];
}

- (void) start
{
    if ( thread == nil )
    {
        thread
            = [[ NSThread alloc ]
                    initWithTarget:self
                          selector:@selector(generate:)
                            object:nil ];
    }

    [ thread start ];
} 

- (void) stop
{
    if ( thread != nil )
    {
        if ( [ thread isExecuting ] == YES )
        {
            // cancel thread
            [ thread cancel ];

            // wake thread up a last time so it exits its main loop
            [ semaphore post ];

            // since NSThreads are created in detached mode
            // we have to join by hand
            while ( [ thread isFinished ] == NO )
            {
                struct timespec request;
                request.tv_sec = (time_t)0;
                request.tv_nsec = 1000000L;
                nanosleep(&request, 0);
            }
        }

        DESTROY(thread);
    }
}

- (ODProjector *) projector
{
    return projector;
}

- (ODProjectedGrid *) projectedGrid
{
    return projectedGrid;
}

- (void) setCamera:(ODCamera *)newCamera
{
    [ projector setCamera:newCamera ];
}

- (BOOL) loadFromDictionary:(NSDictionary *)config
                      error:(NSError **)error
{
    NSAssert(config != nil, @"");

    NSString * oceanName = [ config objectForKey:@"Name" ];
    NSArray  * resolutionStrings = [ config objectForKey:@"Resolution" ];

    if ( resolutionStrings == nil )
    {
        if ( error != NULL )
        {
            *error = nil;
        }
        
        return NO;
    }

    [ self setName:oceanName ];

    IVector2 resolution;
    resolution.x = [[ resolutionStrings objectAtIndex:0 ] intValue ];
    resolution.y = [[ resolutionStrings objectAtIndex:1 ] intValue ];

    [ projectedGrid setResolution:resolution ];

    return YES;
}

- (void) update:(const float)frameTime
{
    [ semaphore post ];

    [ projector     update:frameTime ];
    [ projectedGrid update:frameTime ];
}

- (void) render
{
    [ projectedGrid render ];
    [ projector     render ];
}

@end

