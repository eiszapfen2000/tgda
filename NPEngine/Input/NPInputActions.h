#import "Core/NPObject/NPObject.h"

@interface NPInputActions : NPObject
{
    NSMutableDictionary * inputActions;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (void) reset;

- (id) inputActions;
- (id) inputActionWithName:(NSString *)inputActionName;

- (void) addInputActionWithName:(NSString *)inputActionName
             primaryInputAction:(NpState)primaryInputAction;

- (void) addInputActionWithName:(NSString *)inputActionName
             primaryInputAction:(NpState)primaryInputAction
           secondaryInputAction:(NpState)secondaryInputAction;

- (void) update;

@end
