#import "NPOpenGLRenderContext.h"

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

    active = NO;
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

    return YES;
}

- (void) activate
{
    if ( context != nil && active != YES )
    {
        [ context makeCurrentContext ];

        active = YES;
    }
}

- (void) deactivate
{
    if ( context != nil && active == YES )
    {
        [ NSOpenGLContext clearCurrentContext ];

        active = NO;
    }
}

- (BOOL) isActive
{
    return active;
}

- (void) swap
{
    if ( context != nil && active == YES)
    {
        [ context flushBuffer ];
    }
}

@end
