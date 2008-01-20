#import "Core/NPObject/NPObject.h"
#import "NPOpenGLPixelFormat.h"
#import "NPOpenGLRenderContext.h"

@interface NPOpenGLRenderContextManager : NPObject
{
    NSMutableDictionary * renderContexts;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (NPOpenGLRenderContext *) createRenderContextWithName:(NSString *)name attributes:(NPOpenGLPixelFormatAttributes)pixelFormatAttributes;
- (NPOpenGLRenderContext *) getRenderContextByName:(NSString *)contextName;

@end
