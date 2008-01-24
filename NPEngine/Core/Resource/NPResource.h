#import "Core/NPObject/NPObject.h"
#import "NPPResource.h"

@interface NPResource : NPObject < NPPResource >
{
    NSString * fileName;
    BOOL ready;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;

- (void) setFileName:(NSString *)newFileName;
- (NSString *)fileName;

@end
