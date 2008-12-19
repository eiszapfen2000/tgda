#import "Core/NPObject/NPObject.h"
#import "NPInputConstants.h"

typedef struct NpMouseState
{
    BOOL buttons[5];
    Int deltaX;
    Int deltaY;
    Int scrollWheel;
}
NpMouseState;

void reset_mouse_state(NpMouseState * mouseState);

@class NSEvent;

@interface NPMouse : NPObject
{
    NpMouseState mouseState;
    Int scrollWheelLastFrame;
    Int deltaX;
    Int deltaY;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;

- (Int) deltaX;
- (Int) deltaY;

- (void) processEvent:(NSEvent *)event;

- (BOOL) isAnyButtonPressed;
- (BOOL) isButtonPressed:(NpState)button;
- (NpState *) pressedButtons:(Int *)numberOfPressedButtons;

- (void) update;

@end
