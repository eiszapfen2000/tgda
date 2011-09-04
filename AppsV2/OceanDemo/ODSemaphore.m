#import "ODSemaphore.h"

@implementation ODSemaphore

- (id) init
{
    return [ self initWithValue:0 ];
}

- (id) initWithValue:(const uint32_t)newValue
{
    self = [ super init ];

    sem_init(&semaphore, 0, newValue);

    return self;
}

- (void) dealloc
{
    sem_destroy(&semaphore);

    [ super dealloc ];
}

- (void) post
{
    sem_post(&semaphore);
}

- (void) wait
{
    sem_wait(&semaphore);
}

@end

