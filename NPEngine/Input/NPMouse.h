#import "Core/NPObject/NPObject.h"
#import "NPInputConstants.h"

typedef struct NpMouseState
{
    BOOL buttons[5];
    Int scrollWheel;
}
NpMouseState;

void reset_mouse_state(NpMouseState * mouseState);

@class NSEvent;
@class NSWindow;

@interface NPMouse : NPObject
{
    NpMouseState mouseState;
    Int scrollWheelLastFrame;
    Float x ,y;
    Float xLastFrame, yLastFrame;
    NSWindow * window;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;

- (Float) x;
- (Float) y;
- (Float) deltaX;
- (Float) deltaY;

- (id) window;
- (void) setWindow:(NSWindow *)newWindow;

- (void) resetCursorPosition;

- (void) processEvent:(NSEvent *)event;

- (BOOL) isAnyButtonPressed;
- (BOOL) isButtonPressed:(NpState)button;
- (NpState *) pressedButtons:(Int *)numberOfPressedButtons;

- (void) update;

- (void) setPositionInWindow:(NSPoint)newPosition;

@end
