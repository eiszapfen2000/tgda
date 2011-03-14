#import "Core/Math/IVector.h"
#import "Core/NPObject/NPObject.h"
#import "NPEngineInputEnums.h"

typedef struct NpMouseState
{
    BOOL buttons[8];
    int32_t scrollWheel;
}
NpMouseState;

void reset_mouse_state(NpMouseState * mouseState);

@interface NPMouse : NPObject
{
    NpMouseState mouseState;
    int32_t scrollWheelLastFrame;
    int32_t x ,y;
    int32_t xLastFrame, yLastFrame;
}

- (id) init;

- (int32_t) x;
- (int32_t) y;
- (int32_t) deltaX;
- (int32_t) deltaY;

- (void) setMouseState:(NpMouseState)newMouseState;
- (void) setMousePosition:(IVector2)newMousePosition;

- (BOOL) isAnyButtonPressed;
- (BOOL) isButtonPressed:(NpInputEvent)button;

- (void) update;

@end

