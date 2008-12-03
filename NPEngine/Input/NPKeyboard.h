#import "Core/NPObject/NPObject.h"

typedef struct NpKeyboardState
{
    BOOL keys[256];
}
NpKeyboardState;

void reset_keyboard_state(NpKeyboardState * keyboardState);

@class NSEvent;

@interface NPKeyboard : NPObject
{
    NpKeyboardState keyboardState;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) processEvent:(NSEvent *)event;

- (BOOL) isKeyPressed:(NpState)key;

@end
