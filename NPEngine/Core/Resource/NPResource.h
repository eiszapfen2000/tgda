#import "Core/NPObject/NPObject.h"
#import "NPPResource.h"

@interface NPResource : NPObject
{
    NSString * fileName;
    BOOL ready;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (void) setFileName:(NSString *)newFileName;
- (NSString *)fileName;

- (void) reset;
- (BOOL) isReady;

@end
