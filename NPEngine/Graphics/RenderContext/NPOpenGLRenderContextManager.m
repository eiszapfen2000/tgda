#import "NPOpenGLRenderContextManager.h"

@implementation NPOpenGLRenderContextManager

- (id) init
{
    return [ self initWithName:@"NP Render Context Manager" ];
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

- (NPOpenGLRenderContext *) createRenderContextWithName:(NSString *)contextName attributes:(NPOpenGLPixelFormatAttributes)pixelFormatAttributes
{
    NPOpenGLPixelFormat * pixelFormat = [ [ NPOpenGLPixelFormat alloc ] init ];
    [ pixelFormat setPixelFormatAttributes:pixelFormatAttributes ];
    [ pixelFormat setup ];

    NPOpenGLRenderContext * renderContext = [ [ NPOpenGLRenderContext alloc ] initWithName:contextName parent:self ];
    [ renderContext setupWithPixelFormat:pixelFormat ];
    [ renderContexts setObject:renderContext forKey:contextName ];

    //[ pixelFormat release ];
    //[ renderContext release ];

    return renderContext;
}

- (void) activateRenderContextWithName:(NSString *)contextName
{
    [ [ renderContexts objectForKey:contextName ] activate ];
}

- (NPOpenGLRenderContext *) getRenderContextByName:(NSString *)contextName
{
    return [ renderContexts objectForKey:contextName ];
}

@end
