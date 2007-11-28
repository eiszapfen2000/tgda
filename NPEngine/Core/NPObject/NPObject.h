#import <Foundation/Foundation.h>

#import "Core/Basics/Types.h"

@interface NPObject : NSObject
{
    UInt32 objectID;
    NSString * name;
    NPObject * parent;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (void) addToObjectManager;

- (NSString *) name;
- (void) setName:(NSString *)newName;

- (NPObject *) parent;
- (void) setParent:(NPObject *)newParent;

- (UInt32) objectID;

//private
- (UInt32) _generateIDFromPointer;

@end
