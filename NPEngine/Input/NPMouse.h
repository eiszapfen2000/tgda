#import "Core/NPObject/NPObject.h"
#import "NPInputConstants.h"

typedef struct NpMouseState
{
    BOOL buttons[5];
    Float x;
    Float y;
    Int scrollWheel;
}
NpMouseState;

void reset_mouse_state(NpMouseState * mouseState);

@class NSEvent;

@interface NPMouse : NPObject
{
    NpMouseState mouseState;
    Int scrollWheelLastFrame;
    Float x ,y;
    Float xLastFrame, yLastFrame;
    id window;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;

- (Float) x;
- (Float) y;
- (Float) deltaX;
- (Float) deltaY;

- (id) window;
- (void) setWindow:(id)newWindow;

- (void) processEvent:(NSEvent *)event;

- (BOOL) isAnyButtonPressed;
- (BOOL) isButtonPressed:(NpState)button;
- (NpState *) pressedButtons:(Int *)numberOfPressedButtons;

- (void) update;

- (void) setPosition:(NSPoint)newPosition;

@end
