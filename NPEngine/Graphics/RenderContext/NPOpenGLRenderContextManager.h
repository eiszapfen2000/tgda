#import "Core/NPObject/NPObject.h"
#import "NPOpenGLPixelFormat.h"
#import "NPOpenGLRenderContext.h"

@interface NPOpenGLRenderContextManager : NPObject
{
    NSMutableDictionary * renderContexts;
    NPOpenGLPixelFormat * defaultPixelFormat;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (NPOpenGLPixelFormat *)defaultPixelFormat;
- (void) setDefaultPixelFormat:(NPOpenGLPixelFormat *)newDefaultPixelFormat;

- (NPOpenGLRenderContext *) createRenderContextWithDefaultPixelFormatAndName:(NSString *)contextName;
- (NPOpenGLRenderContext *) createRenderContextWithPixelFormat:(NPOpenGLPixelFormat *)pixelFormat andName:(NSString *)contextName;
- (NPOpenGLRenderContext *) createRenderContextWithAttributes:(NPOpenGLPixelFormatAttributes)pixelFormatAttributes andName:(NSString *)contextName;

- (NPOpenGLRenderContext *) getRenderContextWithName:(NSString *)contextName;

- (void) activateRenderContextWithName:(NSString *)contextName;

@end
