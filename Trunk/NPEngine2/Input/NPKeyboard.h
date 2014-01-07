#import "Core/NPObject/NPObject.h"
#import "NPEngineInputEnums.h"

typedef struct NpKeyboardState
{
    BOOL keys[NpKeyboardEventMax - NpKeyboardEventMin + 1];
}
NpKeyboardState;

void keyboardstate_reset(NpKeyboardState * state);
BOOL keyboardstate_is_any_key_pressed(NpKeyboardState * state);

@interface NPKeyboard : NPObject
{
    NpKeyboardState keyboardState;
}

- (id) init;

- (void) setKeyboardState:(NpKeyboardState *)newKeyboardState;

- (BOOL) isAnyKeyPressed;
- (BOOL) isKeyPressed:(NpInputEvent)key;

@end
