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
}

- (id) initWithName:(NSString *)newName;
- (void) dealloc;

/*
- (NSString *) name;
- (uint32_t) objectID;

- (void) setName:(NSString *)newName;
- (void) setObjectID:(uint32_t)newObjectID;
*/

@end


