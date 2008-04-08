#import "NPCameraManager.h"
#import "NPCamera.h"
#import "Core/NPEngineCore.h"

@implementation NPCameraManager

- (id) init
{
    return [ self initWithParent:nil ];
}

- (id) initWithParent:(NPObject *)newParent
{
    return [ self initWithName:@"NPEngine Camera Manager" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    cameras = [ [ NSMutableArray alloc ] init ];
    currentActiveCamera = nil;

    return self;
}

- (void) dealloc
{
    [ currentActiveCamera release ];
    [ cameras release ];

    [ super dealloc ];
}

- (void) setup
{
    NPLOG(@"NPCameraManager setup...");

    NPLOG(@"Creating Camera...");
    NPCamera * camera = [[ NPCamera alloc ] initWithName:@"" parent:self ];
    [ cameras addObject:camera ];
    [ self setCurrentActiveCamera:camera ];
    [ camera release ];
    NPLOG(@"Camera created");

    NPLOG(@"NPCameraManager ready");
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
