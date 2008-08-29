#import "Core/NPObject/NPObject.h"
#import "NPOpenGLPixelFormat.h"
#import "NPOpenGLRenderContext.h"

@interface NPOpenGLRenderContextManager : NPObject
{
    NSMutableDictionary * renderContexts;
    NPOpenGLPixelFormat * defaultPixelFormat;
    NPOpenGLRenderContext * currentRenderContext;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (NSDictionary *) renderContexts;

- (NPOpenGLPixelFormat *)defaultPixelFormat;
- (void) setDefaultPixelFormat:(NPOpenGLPixelFormat *)newDefaultPixelFormat;

- (NPOpenGLRenderContext *) currentRenderContext;
- (void) setCurrentRenderContext:(NPOpenGLRenderContext *)context;

- (NPOpenGLRenderContext *) createRenderContextWithDefaultPixelFormatAndName:(NSString *)contextName;
- (NPOpenGLRenderContext *) createRenderContextWithPixelFormat:(NPOpenGLPixelFormat *)pixelFormat andName:(NSString *)contextName;
- (NPOpenGLRenderContext *) createRenderContextWithAttributes:(NPOpenGLPixelFormatAttributes)pixelFormatAttributes andName:(NSString *)contextName;

- (void) activateRenderContext:(NPOpenGLRenderContext *)context;
- (void) activateRenderContextWithName:(NSString *)contextName;

@end
