#import <semaphore.h>
#import <Foundation/NSObject.h>

@interface ODSemaphore : NSObject
{
    sem_t semaphore;
}

- (id) init;
- (id) initWithValue:(const uint32_t)newValue;
- (void) dealloc;

- (void) post;
- (void) wait;

@end
