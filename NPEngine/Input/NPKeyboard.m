#import <AppKit/NSEvent.h>
#import "NPKeyboard.h"

void reset_keyboard_state(NpKeyboardState * keyboardState)
{
    for ( Int i = 0; i < 128; i++ )
    {
        keyboardState->keys[i] = NO;
    }
}

void keyboard_state_key_down(NpKeyboardState * keyboardState, NpState key)
{
    keyboardState->keys[key] = YES;
}

void keyboard_state_key_up(NpKeyboardState * keyboardState, NpState key)
{
    keyboardState->keys[key] = NO;
}

void keyboard_state_modifier_key(NpKeyboardState * keyboardState, NpState key)
{
    if ( keyboardState->keys[key] == NO )
    {
        keyboardState->keys[key] = YES;
    }
    else
    {
        keyboardState->keys[key] = NO;
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
    switch ( [ event type ] )
    {
        case NSKeyDown:
        {
            if ( [ event isARepeat ] == NO )
            {
                keyboard_state_key_down(&keyboardState,(NpState)[event keyCode]);
            }
            break;
        }
        case NSKeyUp:
        {
            if ( [ event isARepeat ] == NO )
            {
                keyboard_state_key_up(&keyboardState,(NpState)[event keyCode]);
            }
            break;
        }
        case NSFlagsChanged:
        {
            keyboard_state_modifier_key(&keyboardState,(NpState)[event keyCode]);
            break;
        }

        default:
        {
            break;
        }
    }
}

- (BOOL) isKeyPressed:(NpState)key
{
    return keyboardState.keys[key];
}

@end
