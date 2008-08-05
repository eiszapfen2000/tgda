#import "Core/NPObject/NPObject.h"

@interface NPObjectManager : NSObject < NPPObject >
{
    UInt32 objectID;
    NSString * name;
    NPObject * parent;
    NSMutableArray * objects;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (NSString *) name;
- (void) setName:(NSString *)newName;

- (NPObject *) parent;
- (void) setParent:(NPObject *)newParent;

- (UInt32) objectID;

- (void) addObject:(NSValue *)newObject;
- (void) removeObject:(NSValue *)object;

@end
