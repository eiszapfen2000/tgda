#import <Foundation/NSArray.h>
#import <Foundation/NSString.h>
#import "Core/Protocols/NPPObject.h"

@interface NSArray (NPPObject)

- (id <NPPObject>) objectWithName:(NSString *)name;

@end

@interface NSMutableArray (NPPObject)

- (void) removeObjectWithName:(NSString *)name;

@end

