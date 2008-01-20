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
    [ context release ];

    [ super dealloc ];
}

- (NSOpenGLContext *)context
{
    return context;
}


- (void) setupWithPixelFormat:(NPOpenGLPixelFormat *)pixelFormat
{
    [ pixelFormat retain ];

    context = [ [ NSOpenGLContext alloc ] initWithFormat:[pixelFormat pixelFormat] shareContext:nil ];

    [ pixelFormat release ];
}

- (void) activate
{
    //if ( context != nil )
    //{
        //active = YES;
        [ context makeCurrentContext ];
    //}
}

- (void) deactivate
{
    [ NSOpenGLContext clearCurrentContext ];

    //active = NO;
}

- (BOOL) isActive
{
    return active;
}

- (void) swap
{
    //if ( context != nil )
    {
        [ context flushBuffer ];
    }
}

@end
