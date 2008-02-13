#import "NPOpenGLRenderContextManager.h"

@implementation NPOpenGLRenderContextManager

- (id) init
{
    return [ self initWithName:@"NP RenderContext Manager" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    renderContexts = [ [ NSMutableDictionary alloc ] init ];

    return self;
}

- (void) dealloc
{
    [ renderContexts release ];

    [ super dealloc ];
}

- (NPOpenGLPixelFormat *)defaultPixelFormat
{
    return defaultPixelFormat;
}

- (void) setDefaultPixelFormat:(NPOpenGLPixelFormat *)newDefaultPixelFormat
{
    if ( defaultPixelFormat != newDefaultPixelFormat )
    {
        [ defaultPixelFormat release ];
        defaultPixelFormat = [ newDefaultPixelFormat retain ];
    }
}

- (NPOpenGLRenderContext *) createRenderContextWithDefaultPixelFormatAndName:(NSString *)contextName
{
    if ( [ defaultPixelFormat isReady ] == NO )
    {
        if ( [ defaultPixelFormat setup ] == NO )
        {
            return nil;
        }
    }

    NPOpenGLRenderContext * renderContext = [ [ NPOpenGLRenderContext alloc ] initWithName:contextName parent:self ];

    if ( [ renderContext setupWithPixelFormat:defaultPixelFormat ] == NO )
    {
        return nil;
    }

    [ renderContexts setObject:renderContext forKey:contextName ];
    [ renderContext release ];

    return renderContext;    
}

- (NPOpenGLRenderContext *) createRenderContextWithPixelFormat:(NPOpenGLPixelFormat *)pixelFormat andName:(NSString *)contextName
{
    if ( [ pixelFormat setup ] == NO )
    {
        return nil;
    }
    
    NPOpenGLRenderContext * renderContext = [ [ NPOpenGLRenderContext alloc ] initWithName:contextName parent:self ];

    if ( [ renderContext setupWithPixelFormat:pixelFormat ] == NO )
    {
        return nil;
    }

    [ renderContexts setObject:renderContext forKey:contextName ];

    [ pixelFormat release ];
    [ renderContext release ];

    return renderContext;
}

- (NPOpenGLRenderContext *) createRenderContextWithAttributes:(NPOpenGLPixelFormatAttributes)pixelFormatAttributes andName:(NSString *)contextName
{
    NPOpenGLPixelFormat * pixelFormat = [ [ NPOpenGLPixelFormat alloc ] init ];
    [ pixelFormat setPixelFormatAttributes:pixelFormatAttributes ];

    if ( [ pixelFormat setup ] == NO )
    {
        return nil;
    }
    
    NPOpenGLRenderContext * renderContext = [ [ NPOpenGLRenderContext alloc ] initWithName:contextName parent:self ];

    if ( [ renderContext setupWithPixelFormat:pixelFormat ] == NO )
    {
        return nil;
    }

    [ renderContexts setObject:renderContext forKey:contextName ];

    [ pixelFormat release ];
    [ renderContext release ];

    return renderContext;
}

- (NPOpenGLRenderContext *) getRenderContextWithName:(NSString *)contextName
{
    return [ renderContexts objectForKey:contextName ];
}

- (void) activateRenderContextWithName:(NSString *)contextName
{
    [ [ renderContexts objectForKey:contextName ] activate ];
}

@end
