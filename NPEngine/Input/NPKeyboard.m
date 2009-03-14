#import <AppKit/NSEvent.h>
#import "Core/Basics/NpBasics.h"
#import "NPInputConstants.h"
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

BOOL keyboard_state_is_any_key_pressed(NpKeyboardState * keyboardState)
{
    BOOL result = NO;
    for ( Int i = 0; i < 128; i++ )
    {
        result = ( result || keyboardState->keys[i] );
    }

    return result;
}

NpState * keyboard_state_get_pressed_keys(NpKeyboardState * keyboardState, Int * numberOfPressedKeys)
{
    NpState * pressedKeys = ALLOC_ARRAY(NpState,128);
    *numberOfPressedKeys = 0;

    for ( Int i = 0; i < 128; i++ )
    {
        if ( keyboardState->keys[i] == YES )
        {
            pressedKeys[*numberOfPressedKeys] = (NpState)i;
            (*numberOfPressedKeys)++;
        }
    }

    if ( *numberOfPressedKeys == 0 )
    {
        FREE(pressedKeys);
        return NULL;
    }
    else
    {
        return REALLOC_ARRAY(pressedKeys, NpState, *numberOfPressedKeys);
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

- (BOOL) isAnyKeyPressed
{
    return keyboard_state_is_any_key_pressed(&keyboardState);
}

- (BOOL) isKeyPressed:(NpState)key
{
    return keyboardState.keys[key];
}

- (NpState *) pressedKeys:(Int *)numberOfPressedKeys
{
    return keyboard_state_get_pressed_keys(&keyboardState, numberOfPressedKeys);
}

@end
