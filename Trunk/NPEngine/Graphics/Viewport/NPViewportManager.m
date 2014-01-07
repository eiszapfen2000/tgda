#import "NPViewport.h"
#import "NPViewportManager.h"

@implementation NPViewportManager

- (id) init
{
    return [ self initWithName:@"NPEngine Graphics Viewport Manager" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    viewports = [[ NSMutableArray alloc ] init ];
    currentViewport = [[ NPViewport alloc ] initWithName:@"Default Viewport" parent:self ];
    [ viewports addObject:currentViewport ];    

    return self;
}

- (void) dealloc
{
    RELEASE(currentViewport);
    
    [ viewports removeAllObjects ];
    [ viewports release ];

    [ super dealloc ];
}

- (Float) currentAspectRatio
{
    return [ currentViewport aspectRatio ];
}

- (IVector2 *) currentViewportSize
{
    return [ currentViewport viewportSize ];
}

- (IVector2 *) currentControlSize
{
    return [ currentViewport controlSize ];
}

- (NPViewport *) currentViewport
{
    return currentViewport;
}

- (void) setCurrentViewport:(NPViewport *)newCurrentViewport
{
    ASSIGN(currentViewport, newCurrentViewport);
}

@end
