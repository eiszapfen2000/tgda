#import "Core/NPObject/NPObject.h"
#import "NPEngineInputEnums.h"

@interface NPInputAction : NPObject
{
    NpInputEvent event;
    BOOL active;
    BOOL activeLastFrame;
}

- (id) initWithName:(NSString *)newName 
         inputEvent:(NpInputEvent)newInputEvent;

- (void) dealloc;

- (NpInputEvent) event;
- (BOOL) active;
- (BOOL) activated;
- (BOOL) deactivated;

- (void) update;

@end
