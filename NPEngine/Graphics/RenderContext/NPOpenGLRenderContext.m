#import "NPOpenGLRenderContext.h"
#import "NPOpenGLRenderContextManager.h"
#import "Core/NPEngineCore.h"

@implementation NPOpenGLRenderContext

- (id) init
{
    return [ self initWithName:@"NP OpenGL RenderContext" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    ready = NO;
    active = NO;
    glewInitialised = NO;
    context = nil;

    return self;
}

- (void) dealloc
{
    [ self deactivate ];
    [ context release ];

    [ super dealloc ];
}

- (NSOpenGLContext *)context
{
    return context;
}

- (BOOL) setupWithPixelFormat:(NPOpenGLPixelFormat *)pixelFormat
{
    [ pixelFormat retain ];

    context = [ [ NSOpenGLContext alloc ] initWithFormat:[pixelFormat pixelFormat] shareContext:nil ];

    [ pixelFormat release ];

    if ( context == nil )
    {
        return NO;
    }

    ready = YES;

    return YES;
}

- (void) connectToView:(NSView *)view
{
    //NSLog(@"connect - not ready");
    if ( ready == YES )
    {
        //NSLog(@"np context connectToView");
        [ context setView:view ];
    }
}

- (void) disconnectFromView
{
    //NSLog(@"disconnect - not ready");
    if ( ready == YES )
    {
        //NSLog(@"np context disconnectFromView");
        [ context clearDrawable ];
    }
}

- (NSView *)view
{
    if ( ready == YES )
    {
        return [ context view ];
    }
    else
    {
        return nil;
    }
}

- (void) setupGLEW
{
    if ( glewInitialised == NO )
    {
#define glewGetContext() (&glewContext)
        GLenum err = glewInit();
#undef  glewGetContext

        if (GLEW_OK != err)
        {
            NSLog(@"glewInit failed");
        }
    }
}

- (void) activate
{
    if ( ready == YES && active == NO )
    {
        [[[ NPEngineCore instance ] renderContextManager ] setCurrentlyActiveRenderContext:self ]; 
        [ context makeCurrentContext ];

        active = YES;
    }
}

- (void) deactivate
{
    if ( ready == YES && active == YES )
    {
        [ NSOpenGLContext clearCurrentContext ];
        active = NO;
    }
}

- (BOOL) isActive
{
    return active;
}

- (BOOL) isReady
{
    return ready;
}

- (void) update
{
    if ( ready == YES && active == YES )
    {
        [ context update ];
    }
}

- (void) swap
{
    if ( ready == YES && active == YES )
    {
        [ context flushBuffer ];
    }
}

@end
