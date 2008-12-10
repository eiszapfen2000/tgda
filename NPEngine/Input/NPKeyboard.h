#import "Core/NPObject/NPObject.h"

typedef struct NpKeyboardState
{
    BOOL keys[128];
}
NpKeyboardState;

void reset_keyboard_state(NpKeyboardState * keyboardState);
void keyboard_state_key_down(NpKeyboardState * keyboardState, NpState key);
void keyboard_state_key_up(NpKeyboardState * keyboardState, NpState key);
void keyboard_state_modifier_key(NpKeyboardState * keyboardState, NpState key);
BOOL keyboard_state_is_any_key_pressed(NpKeyboardState * keyboardState);
NpState * keyboard_state_get_pressed_keys(NpKeyboardState * keyboardState, Int * numberOfPressedKeys);

@class NSEvent;

@interface NPKeyboard : NPObject
{
    NpKeyboardState keyboardState;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;

- (void) processEvent:(NSEvent *)event;

- (BOOL) isAnyKeyPressed;
- (BOOL) isKeyPressed:(NpState)key;
- (NpState *) pressedKeys:(Int *)numberOfPressedKeys;

@end
