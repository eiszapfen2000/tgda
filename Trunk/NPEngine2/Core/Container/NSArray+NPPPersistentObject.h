#import <Foundation/NSArray.h>
#import <Foundation/NSString.h>
#import "Core/Protocols/NPPPersistentObject.h"

@interface NSArray (NPPPersistentObject)

- (id <NPPPersistentObject>) objectWithFileName:(NSString *)fileName;

@end

