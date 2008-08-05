#import <Foundation/Foundation.h>

#import "Core/Basics/NpTypes.h"

@interface NPObject : NSObject
{
    UInt32 objectID;
    NSString * name;
    NPObject * parent;
    NSValue * pointer;
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

@end

@interface NPObject ( NPCoding ) < NSCoding > @end

