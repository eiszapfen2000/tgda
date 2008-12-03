#import <AppKit/NSEvent.h>
#import "NPKeyboard.h"


void reset_keyboard_state(NpKeyboardState * keyboardState)
{
    for ( Int i = 0; i < 256; i++ )
    {
        keyboardState->keys[i] = NO;
    }
}

@implementation NPKeyboard

- (id) init
{
    return [ self initWithName:@"NP Engine Keyboard" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    reset_keyboard_state(&keyboardState);

    return self;
}

- (void) dealloc
{
    [ super dealloc ];
}

- (void) processEvent:(NSEvent *)event
{
    NSLog(@"BRAAAAK %d",[event keyCode]);
}

- (BOOL) isKeyPressed:(NpState)key
{
    return keyboardState.keys[key];
}

@end
