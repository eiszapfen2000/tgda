#import "Core/Basics/NpTypes.h"
#import "NPPObject.h"

@class NSPointerArray;
@class NSString;

@interface NPObjectManager : NSObject < NPPObject >
{
    uint32_t objectID;
    NSString * name;
    id <NPPObject> parent;
    NSPointerArray * objects;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (void) addObject:(id <NPPObject>)newObject;
- (void) removeObject:(id <NPPObject>)object;
- (id <NPPObject>) objectByName:(NSString *)objectName;

@end
