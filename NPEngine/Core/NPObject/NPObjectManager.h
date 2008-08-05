#import "Core/NPObject/NPObject.h"

@interface NPObjectManager : NSObject
{
    NSMutableArray * objects;
}

- (id) init;
//- (id) initWithName:(NSString *)newName;
//- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (void) addObject:(NSValue *)newObject;
- (void) removeObject:(NSValue *)object;

@end
