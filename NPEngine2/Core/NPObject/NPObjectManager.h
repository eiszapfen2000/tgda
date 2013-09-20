#import <Foundation/NSLock.h>
#import "Core/Basics/NpTypes.h"
#import "Core/Protocols/NPPObject.h"

@class NSPointerArray;
@class NSString;

@interface NPObjectManager : NSObject < NPPObject >
{
    uint32_t objectID;
    NSString * name;
    NSRecursiveLock * sync;
    NSPointerArray * objects;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (void) addObject:(id <NPPObject>)newObject;
- (void) removeObject:(id <NPPObject>)object;
- (id <NPPObject>) objectByName:(NSString *)objectName;

@end
