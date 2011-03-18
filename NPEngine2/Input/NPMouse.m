#import "Core/Basics/NpBasics.h"
#import "NPMouse.h"

void reset_mouse_state(NpMouseState * mouseState)
{
    memset(mouseState->buttons, 0, sizeof(mouseState->buttons));
    mouseState->scrollWheel = 0;
}

@implementation NPMouse

- (id) init
{
    self = [ super initWithName:@"NPEngine Mouse" ];

    reset_mouse_state(&mouseState);
    scrollWheelLastFrame = 0;
    x = y = 0;
    xLastFrame = yLastFrame = 0;

    return self;
}

- (int32_t) x
{
    return x;
}

- (int32_t) y
{
    return y;
}

- (int32_t) deltaX
{
    return x - xLastFrame;
}

- (int32_t) deltaY
{
    return y - yLastFrame;
}

- (void) setMouseState:(NpMouseState)newMouseState
{
    scrollWheelLastFrame = mouseState.scrollWheel;
    mouseState = newMouseState;
}

- (void) setMousePosition:(IVector2)newMousePosition
{
    xLastFrame = x;
    yLastFrame = y;

    x = newMousePosition.x;
    y = newMousePosition.y;
}

- (void) update
{
}

- (BOOL) isAnyButtonPressed
{
    BOOL result = NO;
    for ( int32_t i = NpMouseEventMin; i <= NpMouseEventMax; i++ )
    {
        result = ( result || [ self isButtonPressed:i ] );
    }

    return result;
}

- (BOOL) isButtonPressed:(NpInputEvent)button
{
    switch ( button )
    {
        case NpMouseButton1:
        case NpMouseButton2:
        case NpMouseButton3:
        case NpMouseButton4:
        case NpMouseButton5:
        case NpMouseButton6:
        case NpMouseButton7:
        case NpMouseButton8:
        {
            return mouseState.buttons[button - 512];
        }

        case NpMouseWheelUp:
        {
            return ( (mouseState.scrollWheel - scrollWheelLastFrame) > 0 );
        }
        case NpMouseWheelDown:
        {
            return ( (mouseState.scrollWheel - scrollWheelLastFrame) < 0 );
        }

        default:
        {
            return NO;
        }
    }

    return NO;   
}

@end
