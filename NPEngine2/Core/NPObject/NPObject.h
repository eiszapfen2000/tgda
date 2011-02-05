#import <Foundation/NSObject.h>
#import <Foundation/NSError.h>
#import <Foundation/NSString.h>
#import <Foundation/NSValue.h>
#import "Core/Basics/NpTypes.h"
#import "Core/Protocols/NPPObject.h"

@interface NPObject : NSObject < NPPObject >
{
    uint32_t objectID;
    NSString * name;
    id <NPPObject> parent;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (NSString *) name;
- (void) setName:(NSString *)newName;

- (id <NPPObject>) parent;
- (void) setParent:(id <NPPObject>)newParent;

- (uint32_t) objectID;

@end


