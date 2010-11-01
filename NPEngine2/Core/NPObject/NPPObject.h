#include <stdint.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>

@protocol NPPObject < NSObject >

//- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;

- (NSString *) name;
- (id <NPPObject>) parent;
- (uint32_t) objectID;

- (void) setName:(NSString *)newName;
- (void) setParent:(id <NPPObject> )newParent;

@end
