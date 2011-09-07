#import "NPSemaphore.h"

@implementation NPSemaphore

- (id) init
{
    return [ self initWithName:@"Semaphore" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName value:0 ];
}

- (id) initWithName:(NSString *)newName
              value:(const uint32_t)newValue
{
    self = [ super initWithName:newName ];

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

