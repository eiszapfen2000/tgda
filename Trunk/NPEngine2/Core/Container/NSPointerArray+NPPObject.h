#import <Foundation/NSPointerArray.h>
#import <Foundation/NSString.h>
#import "Core/Protocols/NPPObject.h"

@interface NSPointerArray (NPPObject)

- (id <NPPObject>) pointerWithName:(NSString *)name;

@end

