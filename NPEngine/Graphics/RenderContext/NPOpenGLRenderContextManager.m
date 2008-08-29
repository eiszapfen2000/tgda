#import "NPOpenGLRenderContextManager.h"
#import "Core/NPEngineCore.h"

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

    renderContexts = [[ NSMutableDictionary alloc ] init ];
    defaultPixelFormat = [[ NPOpenGLPixelFormat alloc ] init ];
    currentRenderContext = nil;

    return self;
}

- (void) dealloc
{
    TEST_RELEASE(currentRenderContext);
    [ renderContexts release ];
    [ defaultPixelFormat release ];

    [ super dealloc ];
}

- (NSDictionary *) renderContexts
{
    return renderContexts;
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

- (NPOpenGLRenderContext *) currentRenderContext
{
    return currentRenderContext;
}

- (void) setCurrentRenderContext:(NPOpenGLRenderContext *)context
{
    if ( context != currentRenderContext )
    {
        [ currentRenderContext release ];
        currentRenderContext = [ context retain ];
    }
}

- (NPOpenGLRenderContext *) createRenderContextWithDefaultPixelFormatAndName:(NSString *)contextName
{
    return [ self createRenderContextWithPixelFormat:defaultPixelFormat andName:contextName ];
}

- (NPOpenGLRenderContext *) createRenderContextWithAttributes:(NPOpenGLPixelFormatAttributes)pixelFormatAttributes andName:(NSString *)contextName
{
    NPOpenGLPixelFormat * pixelFormat = [[ NPOpenGLPixelFormat alloc ] init ];
    [ pixelFormat setPixelFormatAttributes:pixelFormatAttributes ];

    return [ self createRenderContextWithPixelFormat:pixelFormat andName:contextName ];
}

- (NPOpenGLRenderContext *) createRenderContextWithPixelFormat:(NPOpenGLPixelFormat *)pixelFormat andName:(NSString *)contextName
{
    if ( [ pixelFormat chooseMatchingPixelFormat ] == NO )
    {
        NPLOG_ERROR(@"pixelformat hinig");
        return nil;
    }
    
    NPOpenGLRenderContext * renderContext = [ [ NPOpenGLRenderContext alloc ] initWithName:contextName parent:self ];

    if ( [ renderContext setupWithPixelFormat:pixelFormat ] == NO )
    {
		NPLOG_ERROR(@"rendercontext hinig");
        return nil;
    }

    [ renderContexts setObject:renderContext forKey:contextName ];
    [ renderContext release ];

    return renderContext;
}

- (void) activateRenderContext:(NPOpenGLRenderContext *)context
{
    
}

- (void) activateRenderContextWithName:(NSString *)contextName
{
    [ [ renderContexts objectForKey:contextName ] activate ];
}

@end
