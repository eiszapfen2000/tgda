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
    NSLog(@"activate - not ready or not active");
    if ( ready == YES && active == NO )
    {
        NSLog(@"np context activate");
        [[[ NPEngineCore instance ] renderContextManager ] setCurrentlyActiveRenderContext:self ]; 
        [ context makeCurrentContext ];

        active = YES;
    }
}

- (void) deactivate
{
    NSLog(@"deactivate - not ready or not active");
    if ( ready == YES && active == YES )
    {
        [ NSOpenGLContext clearCurrentContext ];
        NSLog(@"np context deactivate");
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
    NSLog(@"update - not ready or not active");
    if ( ready == YES && active == YES )
    {
        NSLog(@"np context update");
        [ context update ];
    }
}

- (void) swap
{
    NSLog(@"swap - not ready or not active");
    if ( ready == YES && active == YES )
    {
        NSLog(@"np context swap");
        [ context flushBuffer ];
    }
}

@end
