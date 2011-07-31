#import "Core/NPObject/NPObject.h"
#import "Core/Protocols/NPPPersistentObject.h"

@interface NPFont : NPObject < NPPPersistentObject >
{
    NSString * file;
    BOOL ready;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

@end

