#import "Core/NPObject/NPObject.h"

@interface NPObjectManager : NPObject
{
    NSMutableArray * objects;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (void) addObject:(NPObject *)newObject;

@end
