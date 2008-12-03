#import "Core/NPObject/NPObject.h"

typedef struct NpMouseState
{
    BOOL buttons[8];
}
NpMouseState;

void reset_mouse_state(NpMouseState * mouseState);

@class NSEvent;

@interface NPMouse : NPObject
{
    NpMouseState mouseState;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) processEvent:(NSEvent *)event;

- (BOOL) isButtonPressed:(NpState)button;

@end
