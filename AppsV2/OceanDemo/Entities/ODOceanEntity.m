#import <Foundation/NSThread.h>
#import "Core/Timer/NPTimer.h"
#import "Core/Thread/NPSemaphore.h"
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
            NSLog(@"BRAK");
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

    thread
        = [[ NSThread alloc ]
                initWithTarget:self
                      selector:@selector(generate:)
                        object:nil ];

    return self;
}

- (void) dealloc
{
    SAFE_DESTROY(stateset);

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

    DESTROY(timer);
    DESTROY(thread);

    [ super dealloc ];
}

- (BOOL) loadFromDictionary:(NSDictionary *)config
                      error:(NSError **)error
{
    return YES;
}

- (void) update:(const float)frameTime
{
}

- (void) render
{
}

@end

