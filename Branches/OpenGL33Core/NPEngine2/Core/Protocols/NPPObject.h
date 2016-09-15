#include <stdint.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>
#import <Foundation/NSException.h>

#ifndef SAFE_DESTROY
#define SAFE_DESTROY(_object)\
({\
if ((_object) != nil )\
DESTROY((_object));\
})
#endif

#ifndef ASSERT_RETAIN
#define ASSERT_RETAIN(_object)\
({\
NSAssert((_object) != nil, @"Attempt to retain nil object");\
RETAIN((_object));\
})
#endif

#ifndef CASSERT_RETAIN
#define CASSERT_RETAIN(_object)\
({\
assert((_object) != nil);\
RETAIN((_object));\
})
#endif


@protocol NPPObject < NSObject >

- (NSString *) name;
- (uint32_t) objectID;

- (void) setName:(NSString *)newName;
- (void) setObjectID:(uint32_t)newObjectID;

@end

