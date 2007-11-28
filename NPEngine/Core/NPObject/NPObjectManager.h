#import "Core/NPObject/NPObject.h"

@interface NPObjectManager : NPObject
{
    NSMutableArray * objects;
}

- (id) init;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;

- (void) addObject:(NPObject *)newObject;

@end
