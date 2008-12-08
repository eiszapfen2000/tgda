#import "NPInputAction.h"
#import "NP.h"

@implementation NPInputAction

- (id) init
{
    return [ self initWithName:@"Dummy Input Action" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent
{
    NPLOG_WARNING(@"Creating NPAction without action");

    return [ super initWithName:newName parent:newParent ];
}

- (id) initWithName:(NSString *)newName 
             parent:(id <NPPObject>)newParent
      primaryAction:(NpState)newPrimaryAction
{
    self = [ super initWithName:newName parent:newParent ];

    events[0] = newPrimaryAction;
    events[1] = -1;

    active = NO;
    activeLastFrame = NO;

    return self;
}

- (id) initWithName:(NSString *)newName 
             parent:(id <NPPObject>)newParent
      primaryAction:(NpState)newPrimaryAction
    secondaryAction:(NpState)newSecondaryAction
{
    self = [ super initWithName:newName parent:newParent ];

    events[0] = newPrimaryAction;
    events[1] = newSecondaryAction;

    active = NO;
    activeLastFrame = NO;

    return self;
}

- (void) dealloc
{
    [ super dealloc ];
}

- (NpState *) events
{
    return events;
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

- (BOOL) isEventActive:(NpState)event
{
    // keyboard event
    if ( event > 0 && event <= 127 )
    {
        return [[[ NP Input ] keyboard ] isKeyPressed:event ];
    }

    return NO;
}

- (void) update
{
    activeLastFrame = active;

    BOOL tmp = NO;
    for ( Int i = 0; i < 2; i++ )
    {
        tmp = ( tmp || [ self isEventActive:events[i] ] );
    }

    active = tmp;
}

@end
