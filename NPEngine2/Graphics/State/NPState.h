#import "Core/NPObject/NPObject.h"

@class NPStateConfiguration;

@interface NPState : NPObject
{
    NPStateConfiguration * configuration;
    BOOL locked;
}

- (id) initWithName:(NSString *)newName 
      configuration:(NPStateConfiguration *)newConfiguration;

- (void) dealloc;

- (BOOL) locked;
- (void) setLocked:(BOOL)newLocked;

- (BOOL) changeable;

@end
