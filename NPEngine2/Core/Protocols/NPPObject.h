#include <stdint.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>

#ifdef DESTROY
#define SAFE_DESTROY(_object) { if ( (_object) != nil ) DESTROY((_object)); }
#endif

@protocol NPPObject < NSObject >

- (NSString *) name;
- (id <NPPObject>) parent;
- (uint32_t) objectID;

- (void) setName:(NSString *)newName;
- (void) setParent:(id <NPPObject> )newParent;

@end

