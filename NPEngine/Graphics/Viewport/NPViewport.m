#import "NPViewport.h"
#import "NP.h"

@implementation NPViewport

- (id) init
{
    return [ self initWithName:@"NPViewport" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    controlSize = iv2_alloc_init();
    viewportSize = iv2_alloc_init();
    viewportOrigin = iv2_alloc_init();
    viewportSizeLastFrame = iv2_alloc_init();
    viewportOriginLastFrame = iv2_alloc_init();

    return self;
}

- (void) dealloc
{
    iv2_free(viewportOriginLastFrame);
    iv2_free(viewportSizeLastFrame);
    iv2_free(viewportOrigin);
    iv2_free(viewportSize);
    iv2_free(controlSize);

    [ super dealloc ];
}

- (Float) aspectRatio
{
    return ((Float)viewportSize->x/(Float)viewportSize->y);
}

- (IVector2 *) controlSize
{
    return controlSize;
}

- (IVector2 *) viewportSize
{
    return viewportSize;
}

- (void) setControlSize:(IVector2 *)newControlSize
{
    *controlSize = *newControlSize;
}

- (void) setViewportSize:(IVector2 *)newViewportSize;
{
    *viewportSizeLastFrame = *viewportSize;
    *viewportSize = *newViewportSize;

    glViewport(0, 0, viewportSize->x, viewportSize->y);
}

- (void) setToControlSize
{
    glViewport(0, 0, controlSize->x, controlSize->y);
}

// reset opengl viewport to the control's size, will be called every frame
/*- (void) render
{
    if ( [[[ NP Graphics ] renderTargetManager ] currentRenderTargetConfiguration ] != nil )
    {
        viewportSizeLastFrame = renderTargetSize;
        glViewport(0,0,renderTargetSize.x,renderTargetSize.y);
    }
    else if ( (viewportSizeLastFrame.x != viewportSize.x)     ||
              (viewportSizeLastFrame.y != viewportSize.y)     ||
              (viewportOriginLastFrame.x != viewportOrigin.x) ||
              (viewportOriginLastFrame.y != viewportOrigin.y) )
    {
        glViewport(viewportOrigin.x,viewportOrigin.y,viewportSize.x,viewportSize.y);
    }
}*/

@end
