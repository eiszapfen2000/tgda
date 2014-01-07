#import <semaphore.h>
#import "Core/NPObject/NPObject.h"

@interface NPSemaphore : NPObject
{
    sem_t semaphore;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName
              value:(const uint32_t)newValue
                   ;

- (void) dealloc;

- (void) post;
- (void) wait;

@end
