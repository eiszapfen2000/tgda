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
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (NSString *) name;
- (id <NPPObject>) parent;
- (UInt32) objectID;

- (void) setName:(NSString *)newName;
- (void) setParent:(id <NPPObject>)newParent;

- (void) addObject:(NSValue *)newObject;
- (void) removeObject:(NSValue *)object;
- (id <NPPObject>) objectByName:(NSString *)objectName;

@end
