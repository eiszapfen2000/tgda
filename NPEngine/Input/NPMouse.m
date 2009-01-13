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
    //NSPoint newMousePoint = [ window convertScreenToBase:mousePoint ];
    mouseState.x = mousePoint.x;
    mouseState.y = mousePoint.y;
    x = xLastFrame = mouseState.x;
    y = yLastFrame = mouseState.y;
    //NSLog(@"window %f %f",x,y);
}

- (Float) deltaX
{
    //NSLog(@"%f",(x - xLastFrame));
    return x - xLastFrame;
}

- (Float) deltaY
{
    //NSLog(@"%f",(y - yLastFrame));
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
            /*mouseState.xLastFrame = mouseState.x;
            mouseState.yLastFrame = mouseState.y;
            //NSLog(@"%f %f",mouseState.x,mouseState.y);*/

            NSPoint mouseLocationInWindow = [ event locationInWindow ];
            //NSLog(@"Loc %f %f",mouseLocationInWindow.x,mouseLocationInWindow.y);
            //NSLog(@"Delta %f %f",[ event deltaX ], [ event deltaY ]);
            
            mouseState.x = mouseLocationInWindow.x;
            mouseState.y = mouseLocationInWindow.y;
            //NSLog(@"moved %f %f",mouseState.x,mouseState.y);

            /*if ( useLastFrameDeltas == NO )
            {
                mouseState.deltaXLastFrame = mouseState.deltaX;
                mouseState.deltaYLastFrame = mouseState.deltaY;
                mouseState.deltaX = mouseState.x - mouseState.xLastFrame;
                mouseState.deltaY = mouseState.y - mouseState.yLastFrame;
            }
            else
            {
                mouseState.deltaX = mouseState.deltaXLastFrame;
                mouseState.deltaY = mouseState.deltaYLastFrame;
            }*/
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
    /*mouseState.x = newPosition.x;
    mouseState.y = newPosition.y;
    mouseState.xLastFrame = newPosition.x;
    mouseState.yLastFrame = newPosition.y;*/

    //x = xLastFrame = newPosition.x;
    //y = yLastFrame = newPosition.y;

    if ( x > 800.0f || x <= 200.0f || y > 650.0f || y < 150.0f )
    {
        [ GSCurrentServer() setmouseposition:newPosition.x :newPosition.y :[ window windowNumber ] ];
    }

    //useLastFrameDeltas = YES;
}

- (void) update
{
    scrollWheelLastFrame = mouseState.scrollWheel;
    xLastFrame = x;
    yLastFrame = y;

    x = mouseState.x;
    y = mouseState.y;

    /*NSPoint mousePoint = [ window mouseLocationOutsideOfEventStream ];
    x = mousePoint.x;
    y = mousePoint.y;*/
    //NSLog(@"%f %f",x,y);
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
