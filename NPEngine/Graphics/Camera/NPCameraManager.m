#import "NPCameraManager.h"

@implementation NPCameraManager

- (id) init
{
    return [ self initWithParent:nil ];
}

- (id) initWithParent:(NPObject *)newParent
{
    return [ self initWithName:@"NP Camera Manager" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    cameras = [ [ NSMutableArray alloc ] init ];

    return self;
}

@end
