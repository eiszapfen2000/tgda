#import <AppKit/NSEvent.h>
#import "NPMouse.h"

void reset_mouse_state(NpMouseState * mouseState)
{
    for ( Int i = 0; i < 8; i++ )
    {
        mouseState->buttons[i] = NO;
    }
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
    NSLog(@"Button %d",[event clickCount]);
}

- (BOOL) isButtonPressed:(NpState)button
{
    return mouseState.buttons[button];
}

@end
