#import "Core/NPObject/NPObject.h"

@interface TOOceanSurface : NPObject
{
    Float * positions;
    Int * indices;

    BOOL ready;
    BOOL changed;
}

- (id) init;
- (id) initWithParent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (void) setup;

@end
