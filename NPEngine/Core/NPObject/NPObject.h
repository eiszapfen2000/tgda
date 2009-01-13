#import <Foundation/Foundation.h>

#import "Core/Basics/NpTypes.h"
#import "NPPCoreProtocols.h"

@interface NPObject : NSObject < NPPObject >
{
    UInt32 objectID;
    NSString * name;
    NPObject * parent;
    NSValue * pointer;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (NSString *) name;
- (void) setName:(NSString *)newName;

- (id <NPPObject>) parent;
- (void) setParent:(id <NPPObject>)newParent;

- (UInt32) objectID;

@end

@interface NPObject ( NPCoding ) < NSCoding > @end

