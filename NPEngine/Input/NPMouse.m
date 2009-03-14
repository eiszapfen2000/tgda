#import <AppKit/NSEvent.h>
#import <AppKit/NSWindow.h>
#import <GNUstepGUI/GSDisplayServer.h>
#import "Core/Basics/NpBasics.h"
#import "NPInputConstants.h"
#import "NPMouse.h"

void reset_mouse_state(NpMouseState * mouseState)
{
    for ( Int i = 0; i < 5; i++ )
    {
        mouseState->buttons[i] = NO;
    }

    mouseState->x = 0.0f;
    mouseState->y = 0.0f;
    mouseState->scrollWheel = 0;
}

@implementation NPMouse

- (id) init
{
    return [ self initWithName:@"NP Engine Mouse" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    reset_mouse_state(&mouseState);
    scrollWheelLastFrame = 0;
    x = y = 0.0f;
    xLastFrame = yLastFrame = 0.0f;

    return self;
}

- (void) dealloc
{
    [ super dealloc ];
}

- (id) window
{
    return window;
}

- (void) setWindow:(id)newWindow
{
    window = newWindow;

    NSPoint mousePoint = [ window mouseLocationOutsideOfEventStream ];
    mouseState.x = mousePoint.x;
    mouseState.y = mousePoint.y;
    x = xLastFrame = mouseState.x;
    y = yLastFrame = mouseState.y;
}

- (Float) x
{
    return x;
}

- (Float) y
{
    return y;
}

- (Float) deltaX
{
    return x - xLastFrame;
}

- (Float) deltaY
{
    return y - yLastFrame;
}

- (void) processEvent:(NSEvent *)event
{
    mouseState.scrollWheel = 0;

    Int buttonIndex;
    switch ( [ event type ] )
    {
        case NSLeftMouseDown:
        {
            mouseState.buttons[0] = YES;
            break;
        }

        case NSLeftMouseUp:
        {
            mouseState.buttons[0] = NO;
            break;
        }

        case NSRightMouseDown:
        {
            mouseState.buttons[2] = YES;
            break;
        }

        case NSRightMouseUp:
        {
            mouseState.buttons[2] = NO;
            break;
        }

        case NSOtherMouseDown:
        {
            buttonIndex = [ event buttonNumber ] - 1;
            mouseState.buttons[buttonIndex] = YES;
            break;
        }

        case NSOtherMouseUp:
        {
            buttonIndex = [ event buttonNumber ] - 1;
            mouseState.buttons[buttonIndex] = NO;
            break;
        }

        case NSMouseMoved:
        {
            NSPoint mouseLocationInWindow = [ event locationInWindow ];
            
            mouseState.x = mouseLocationInWindow.x;
            mouseState.y = mouseLocationInWindow.y;

            break;
        }

        case NSScrollWheel:
        {
            mouseState.scrollWheel = (Int)[ event deltaY ];
        }

        default:
        {
            break;
        }
    }
}
- (void) setPosition:(NSPoint)newPosition
{
    [ GSCurrentServer() setmouseposition:newPosition.x :newPosition.y :[ window windowNumber ]];

    x = xLastFrame = newPosition.x;
    y = yLastFrame = newPosition.y;
}

- (void) update
{
    scrollWheelLastFrame = mouseState.scrollWheel;
    xLastFrame = x;
    yLastFrame = y;

    x = mouseState.x;
    y = mouseState.y;
}

- (BOOL) isAnyButtonPressed
{
    BOOL result = NO;
    for ( Int i = NP_INPUT_MOUSE_BUTTON_LEFT; i <= NP_INPUT_MOUSE_WHEEL_DOWN; i++ )
    {
        result = ( result || [ self isButtonPressed:i ] );
    }

    return result;
}

- (BOOL) isButtonPressed:(NpState)button
{
    switch ( button )
    {
        case NP_INPUT_MOUSE_BUTTON_LEFT:
        case NP_INPUT_MOUSE_BUTTON_MIDDLE:
        case NP_INPUT_MOUSE_BUTTON_RIGHT:
        case NP_INPUT_MOUSE_BUTTON_4:
        case NP_INPUT_MOUSE_BUTTON_5:
        {
            return mouseState.buttons[button - 256];
        }

        case NP_INPUT_MOUSE_WHEEL_UP:
        {
            return ( (mouseState.scrollWheel - scrollWheelLastFrame) > 0 );
        }
        case NP_INPUT_MOUSE_WHEEL_DOWN:
        {
            return ( (mouseState.scrollWheel - scrollWheelLastFrame) < 0 );
        }
    }

    return NO;   
}

- (NpState *) pressedButtons:(Int *)numberOfPressedButtons
{
    *numberOfPressedButtons = 0;
    NpState * pressedButtons = ALLOC_ARRAY(NpState,7);

    for ( Int i = NP_INPUT_MOUSE_BUTTON_LEFT; i <= NP_INPUT_MOUSE_WHEEL_DOWN; i++ )
    {
        if ( [ self isButtonPressed:i ] )
        {
            pressedButtons[*numberOfPressedButtons] = i;
            (*numberOfPressedButtons)++;
        }
    }

    if ( *numberOfPressedButtons == 0 )
    {
        FREE(pressedButtons);
        return NULL;
    }
    else
    {
        return REALLOC_ARRAY(pressedButtons, NpState, *numberOfPressedButtons);
    }
}

@end
