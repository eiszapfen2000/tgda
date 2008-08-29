#import "Core/NPObject/NPObject.h"

@interface ODScene : NPObject
{
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (void) update;
- (void) render;

@end
