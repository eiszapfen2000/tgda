#import <Foundation/NSArray.h>
#import <Foundation/NSValue.h>
#import "Core/NPObject/NPPObject.h"

@interface NPObjectManager : NSObject < NPPObject >
{
    uint32_t objectID;
    NSString * name;
    id <NPPObject> parent;
    NSMutableArray * objects;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (void) addObject:(NSValue *)newObject;
- (void) removeObject:(NSValue *)object;
- (id <NPPObject>) objectByName:(NSString *)objectName;

@end
