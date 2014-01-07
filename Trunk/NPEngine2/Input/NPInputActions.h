#import "Core/NPObject/NPObject.h"
#import "NPEngineInputEnums.h"

@class NSMutableArray;

@interface NPInputActions : NPObject
{
    NSMutableArray * inputActions;
}

- (id) init;
- (void) dealloc;

- (void) reset;

- (id) inputActionWithName:(NSString *)inputActionName;

- (void) removeInputActionWithName:(NSString *)inputActionName;
- (void) removeInputAction:(id)inputAction;
- (id) addInputActionWithName:(NSString *)inputActionName
                   inputEvent:(NpInputEvent)newInputEvent
                             ;

- (void) update;

@end
