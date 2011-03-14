#import "Core/Protocols/NPPObject.h"
#import "NPEngineInputEnums.h"

@class NPMouse;
@class NPInputActions;

@interface NPEngineInput : NSObject < NPPObject >
{
    uint32_t objectID;
    NPMouse * mouse;
    NPInputActions * inputActions;
}

+ (NPEngineInput *) instance;

- (id) init;
- (void) dealloc;

- (NPMouse *) mouse;
- (NPInputActions *) inputActions;

- (void) update;
- (BOOL) isAnythingPressed;

@end

