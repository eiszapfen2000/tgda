#import "Core/NPObject/NPObject.h"

#define NP_INPUT_NONE   0

@interface NPInputAction : NPObject
{
    NpState events[2];
    BOOL active;
    BOOL activeLastFrame;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;

- (id) initWithName:(NSString *)newName 
             parent:(id <NPPObject>)newParent
      primaryAction:(NpState)newPrimaryAction;

- (id) initWithName:(NSString *)newName 
             parent:(id <NPPObject>)newParent
      primaryAction:(NpState)newPrimaryAction
    secondaryAction:(NpState)newSecondaryAction;

- (void) dealloc;

- (NpState *) events;
- (BOOL) active;
- (BOOL) activated;
- (BOOL) deactivated;

- (void) update;

@end
