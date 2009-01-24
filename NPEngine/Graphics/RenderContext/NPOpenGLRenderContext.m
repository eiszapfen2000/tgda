#import "NPOpenGLRenderContext.h"
#import "NPOpenGLRenderContextManager.h"
#import "NP.h"

@implementation NPOpenGLRenderContext

- (id) init
{
    return [ self initWithName:@"NP OpenGL RenderContext" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
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
    ready = NO;

    [ pixelFormat retain ];
    context = [[ NSOpenGLContext alloc ] initWithFormat:[pixelFormat pixelFormat] shareContext:nil ];
    [ pixelFormat release ];

    if ( context != nil )
    {
        ready = YES;
    }

    return ready;
}

- (void) connectToView:(NSView *)view
{
    if ( ready == YES )
    {
        [ context setView:view ];
    }
}

- (void) disconnectFromView
{
    if ( ready == YES )
    {
        [ context clearDrawable ];
    }
}

- (NSView *) view
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
#define glxewGetContext() (&glxewContext)

        GLenum err = glewInit();

        if (GLEW_OK != err)
        {
            NPLOG_ERROR(@"glewInit failed");
        }

        err = glxewInit();

        if (GLEW_OK != err)
        {
            NPLOG_ERROR(@"glxewInit failed");
        }
    }
}

- (GLEWContext *)glewContext
{
    return &glewContext;
}

- (void) activate
{
    if ( ready == YES && active == NO )
    {
        [[[ NP Graphics] renderContextManager ] setCurrentRenderContext:self ]; 
        [ context makeCurrentContext ];

        active = YES;
    }
}

- (void) deactivate
{
    if ( ready == YES && active == YES )
    {
        [[[ NP Graphics ] renderContextManager ] setCurrentRenderContext:nil ]; 
        [ NSOpenGLContext clearCurrentContext ];
        active = NO;
    }
}

- (BOOL) active
{
    return active;
}

- (BOOL) ready
{
    return ready;
}

- (void) update
{
    //if ( ready == YES && active == YES )
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

- (BOOL) isExtensionSupported:(NSString *)extensionString
{
    const char * extensionCString = [ extensionString cStringUsingEncoding:NSUTF8StringEncoding ];
    BOOL tmp = glewIsSupported(extensionCString);

    if ( tmp == YES )
    {
        NPLOG(@"%@: extension %@ supported", name, extensionString);
    }
    else
    {
        NPLOG(@"%@: extension %@ not supported", name, extensionString);
    }

    return tmp;
}

@end

#undef glewGetContext
#undef glxewGetContext
