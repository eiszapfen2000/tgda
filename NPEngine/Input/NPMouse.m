#import <AppKit/NSEvent.h>
#import "Core/Basics/NpBasics.h"
#import "NPInputConstants.h"
#import "NPMouse.h"

void reset_mouse_state(NpMouseState * mouseState)
{
    for ( Int i = 0; i < 5; i++ )
    {
        mouseState->buttons[i] = NO;
    }

    mouseState->deltaX = 0.0f;
    mouseState->deltaY = 0.0f;
    mouseState->scrollWheel = 0.0;
    mouseState->scrollWheelLastFrame = 0.0;
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

    return self;
}

- (void) dealloc
{
    [ super dealloc ];
}

- (void) processEvent:(NSEvent *)event
{
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
            mouseState.deltaX = (Int)[ event deltaX ];
            mouseState.deltaY = (Int)[ event deltaY ];
            break;
        }

        case NSScrollWheel:
        {
            mouseState.scrollWheelLastFrame = mouseState.scrollWheel;
            mouseState.scrollWheel = (Int)[ event deltaY ];
        }

        default:
        {
            break;
        }
    }
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
            return ( (mouseState.scrollWheel - mouseState.scrollWheelLastFrame) > 0 );
        }
        case NP_INPUT_MOUSE_WHEEL_DOWN:
        {
            return ( (mouseState.scrollWheel - mouseState.scrollWheelLastFrame) < 0 );
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
