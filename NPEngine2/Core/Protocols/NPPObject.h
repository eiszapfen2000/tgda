#include <stdint.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>

#ifdef DESTROY
#define SAFE_DESTROY(_object) { if ( (_object) != nil ) DESTROY((_object)); }
#endif

@protocol NPPObject < NSObject >

- (NSString *) name;
- (uint32_t) objectID;

- (void) setName:(NSString *)newName;
- (void) setObjectID:(uint32_t)newObjectID;

@end

