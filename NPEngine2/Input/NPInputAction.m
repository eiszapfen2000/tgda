#import "NPEngineInput.h"
#import "NPKeyboard.h"
#import "NPMouse.h"
#import "NPInputAction.h"

@implementation NPInputAction

- (id) initWithName:(NSString *)newName 
         inputEvent:(NpInputEvent)newInputEvent
{
    self = [ super initWithName:newName ];

    event = newInputEvent;
    active = activeLastFrame = NO;

    return self;
}

- (void) dealloc
{
    [ super dealloc ];
}

- (NpInputEvent) event
{
    return event;
}

- (BOOL) active
{
    return active;
}

- (BOOL) activated
{
    return ( active && (!activeLastFrame) );
}

- (BOOL) deactivated
{
    return ( (!active) && activeLastFrame );
}

- (BOOL) isEventActive:(NpInputEvent)inputEvent 
{
    return ( [[[ NPEngineInput instance ] mouse ] isButtonPressed:event ]
             || [[[ NPEngineInput instance ] keyboard ] isKeyPressed:event ] );
}

- (void) update
{
    activeLastFrame = active;
    active = [ self isEventActive:event ];
}

@end
