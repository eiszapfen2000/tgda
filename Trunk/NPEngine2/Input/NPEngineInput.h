#import "Core/Protocols/NPPObject.h"
#import "NPEngineInputEnums.h"

@class NPKeyboard;
@class NPMouse;
@class NPInputActions;

@interface NPEngineInput : NSObject < NPPObject >
{
    uint32_t objectID;
    NPKeyboard * keyboard;
    NPMouse * mouse;
    NPInputActions * inputActions;
}

+ (NPEngineInput *) instance;

- (id) init;
- (void) dealloc;

- (NPKeyboard *) keyboard;
- (NPMouse *) mouse;
- (NPInputActions *) inputActions;

- (void) update;
- (BOOL) isAnythingPressed;

@end

