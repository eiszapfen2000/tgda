#import "ODScene.h"

@implementation ODScene

- (id) init
{
    return [ self initWithName:@"ODScene" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    return [ super initWithName:newName parent:newParent ];
}

- (void) dealloc
{
    [ super dealloc ];
}

- (void) update
{
}

- (void) render
{
}

@end
