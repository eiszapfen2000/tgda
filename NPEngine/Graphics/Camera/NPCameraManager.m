#import "NPCameraManager.h"
#import "NPCamera.h"

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
    currentActiveCamera = nil;

    return self;
}

- (NPCamera *) currentActiveCamera
{
    return currentActiveCamera;
}

- (void) setCurrentActiveCamera:(NPCamera *)newCurrentActiveCamera
{
    if ( currentActiveCamera != newCurrentActiveCamera )
    {
        [ currentActiveCamera release ];
        currentActiveCamera = [ newCurrentActiveCamera retain ];
    }
}


@end
