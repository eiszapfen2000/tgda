#import <Foundation/NSPointerArray.h>
#import <Foundation/NSString.h>
#import "Core/Protocols/NPPPersistentObject.h"

@interface NSPointerArray (NPPPersistentObject)

- (id <NPPPersistentObject>) pointerWithFileName:(NSString *)fileName;

@end

