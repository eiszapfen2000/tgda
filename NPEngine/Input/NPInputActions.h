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

- (id) addInputActionWithName:(NSString *)inputActionName
           primaryInputAction:(NpState)primaryInputAction;

- (id) addInputActionWithName:(NSString *)inputActionName
           primaryInputAction:(NpState)primaryInputAction
         secondaryInputAction:(NpState)secondaryInputAction;

- (void) update;

@end
