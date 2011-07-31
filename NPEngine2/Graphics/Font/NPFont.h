#import "Core/NPObject/NPObject.h"
#import "Core/Protocols/NPPPersistentObject.h"

@class NSMutableArray;

@interface NPFont : NPObject < NPPPersistentObject >
{
    NSString * file;
    BOOL ready;

    NSMutableArray * characterPages;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

@end

