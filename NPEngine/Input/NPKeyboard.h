#import "Core/NPObject/NPObject.h"

#define NP_INPUT_KEYBOARD_A 38
#define NP_INPUT_KEYBOARD_B 56
#define NP_INPUT_KEYBOARD_C 54
#define NP_INPUT_KEYBOARD_D 40
#define NP_INPUT_KEYBOARD_E 26
#define NP_INPUT_KEYBOARD_F 41
#define NP_INPUT_KEYBOARD_G 42
#define NP_INPUT_KEYBOARD_H 43
#define NP_INPUT_KEYBOARD_I 31
#define NP_INPUT_KEYBOARD_J 44
#define NP_INPUT_KEYBOARD_K 45
#define NP_INPUT_KEYBOARD_L 46
#define NP_INPUT_KEYBOARD_M 58
#define NP_INPUT_KEYBOARD_N 57
#define NP_INPUT_KEYBOARD_O 32
#define NP_INPUT_KEYBOARD_P 33
#define NP_INPUT_KEYBOARD_Q 24
#define NP_INPUT_KEYBOARD_R 27
#define NP_INPUT_KEYBOARD_S 39
#define NP_INPUT_KEYBOARD_T 28
#define NP_INPUT_KEYBOARD_U 30
#define NP_INPUT_KEYBOARD_V 55
#define NP_INPUT_KEYBOARD_W 25
#define NP_INPUT_KEYBOARD_X 53
#define NP_INPUT_KEYBOARD_Y 52
#define NP_INPUT_KEYBOARD_Z 29

#define NP_INPUT_KEYBOARD_1 10
#define NP_INPUT_KEYBOARD_2 11
#define NP_INPUT_KEYBOARD_3 12
#define NP_INPUT_KEYBOARD_4 13
#define NP_INPUT_KEYBOARD_5 14
#define NP_INPUT_KEYBOARD_6 15
#define NP_INPUT_KEYBOARD_7 16
#define NP_INPUT_KEYBOARD_8 17
#define NP_INPUT_KEYBOARD_9 18
#define NP_INPUT_KEYBOARD_0 19

#define NP_INPUT_KEYBOARD_LEFT_SHIFT     50
#define NP_INPUT_KEYBOARD_RIGHT_SHIFT    62
#define NP_INPUT_KEYBOARD_LEFT_CONTROL   37
#define NP_INPUT_KEYBOARD_RIGHT_CONTROL 109
#define NP_INPUT_KEYBOARD_ALT            64
#define NP_INPUT_KEYBOARD_ALTGR         113
#define NP_INPUT_KEYBOARD_TAB            23
#define NP_INPUT_KEYBOARD_CAPSLOCK       66
#define NP_INPUT_KEYBOARD_ENTER          36

#define NP_INPUT_KEYBOARD_END       103
#define NP_INPUT_KEYBOARD_PAGE_DOWN 105
#define NP_INPUT_KEYBOARD_PAGE_UP    99
#define NP_INPUT_KEYBOARD_HOME       97
#define NP_INPUT_KEYBOARD_DELETE    107
#define NP_INPUT_KEYBOARD_BACKSPACE  22
#define NP_INPUT_KEYBOARD_INSERT    106
#define NP_INPUT_KEYBOARD_NUM        77
#define NP_INPUT_KEYBOARD_ESCAPE      9

#define NP_INPUT_KEYBOARD_UP     98
#define NP_INPUT_KEYBOARD_DOWN  104
#define NP_INPUT_KEYBOARD_LEFT  100
#define NP_INPUT_KEYBOARD_RIGHT 102

#define NP_INPUT_KEYBOARD_F1  67
#define NP_INPUT_KEYBOARD_F2  68
#define NP_INPUT_KEYBOARD_F3  69
#define NP_INPUT_KEYBOARD_F4  70
#define NP_INPUT_KEYBOARD_F5  71
#define NP_INPUT_KEYBOARD_F6  72
#define NP_INPUT_KEYBOARD_F7  73
#define NP_INPUT_KEYBOARD_F8  74
#define NP_INPUT_KEYBOARD_F9  75
#define NP_INPUT_KEYBOARD_F10 76
#define NP_INPUT_KEYBOARD_F11 95
#define NP_INPUT_KEYBOARD_F12 96

#define NP_INPUT_KEYBOARD_PLUS  35
#define NP_INPUT_KEYBOARD_HASH  51
#define NP_INPUT_KEYBOARD_LINE  61
#define NP_INPUT_KEYBOARD_DOT   60
#define NP_INPUT_KEYBOARD_COMMA 59

/*
#define NP_INPUT_KEYBOARD_UE 34
#define NP_INPUT_KEYBOARD_AE 48
#define NP_INPUT_KEYBOARD_OE 47
*/

typedef struct NpKeyboardState
{
    BOOL keys[128];
}
NpKeyboardState;

void reset_keyboard_state(NpKeyboardState * keyboardState);
void keyboard_state_key_down(NpKeyboardState * keyboardState, NpState key);
void keyboard_state_key_up(NpKeyboardState * keyboardState, NpState key);
void keyboard_state_modifier_key(NpKeyboardState * keyboardState, NpState key);

@class NSEvent;

@interface NPKeyboard : NPObject
{
    NpKeyboardState keyboardState;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;

- (void) processEvent:(NSEvent *)event;

- (BOOL) isKeyPressed:(NpState)key;

@end
