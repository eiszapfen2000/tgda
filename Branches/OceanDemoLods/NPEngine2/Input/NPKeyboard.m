#import "Core/Basics/NpBasics.h"
#import "NPKeyboard.h"

void keyboardstate_reset(NpKeyboardState * state)
{
    memset(state, 0, sizeof(NpKeyboardState));
}

BOOL keyboardstate_is_any_key_pressed(NpKeyboardState * state)
{
    BOOL result = NO;
    for ( int32_t i = NpKeyboardEventMin; i <= NpKeyboardEventMax; i++ )
    {
        result = ( result || state->keys[i] );
    }

    return result;
}

@implementation NPKeyboard

- (id) init
{
    self = [ super initWithName:@"NPEngine Keyboard" ];

    keyboardstate_reset(&keyboardState);

    return self;
}

- (void) setKeyboardState:(NpKeyboardState *)newKeyboardState
{
    keyboardState = *newKeyboardState;
}

- (BOOL) isAnyKeyPressed
{
    return keyboardstate_is_any_key_pressed(&keyboardState);
}

- (BOOL) isKeyPressed:(NpInputEvent)key
{
    if ( key < NpKeyboardEventMin || key > NpKeyboardEventMax )
    {
        return NO;
    }

    return keyboardState.keys[key];
}

@end

