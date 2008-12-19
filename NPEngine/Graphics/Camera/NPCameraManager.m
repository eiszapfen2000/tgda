#import "NPCameraManager.h"
#import "NPCamera.h"

#import "NP.h"

@implementation NPCameraManager

- (id) init
{
    return [ self initWithParent:nil ];
}

- (id) initWithParent:(id <NPPObject> )newParent
{
    return [ self initWithName:@"NPEngine Camera Manager" parent:newParent ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
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
    NPCamera * camera = [[ NPCamera alloc ] initWithName:@"Default Camera" parent:self ];
    [ cameras addObject:camera ];
    [ self setCurrentActiveCamera:camera ];
    [ camera release ];
    NPLOG(@"Camera created");

    NPLOG(@"NPCameraManager ready");
}

- (id) currentActiveCamera
{
    return currentActiveCamera;
}

- (void) setCurrentActiveCamera:(id)newCurrentActiveCamera
{
    if ( currentActiveCamera != newCurrentActiveCamera )
    {
        [ currentActiveCamera release ];
        currentActiveCamera = [ newCurrentActiveCamera retain ];
    }
}

- (id) createCamera
{
    NPCamera * camera = [[ NPCamera alloc ] initWithParent:self ];
    [ cameras addObject:camera ];
    [ camera release ];

    return camera;
}

@end
