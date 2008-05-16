#import "Core/NPObject/NPObject.h"

@class NPCamera;
@class NPSUXModel;
@class NPSUXModelLod;
@class NPSUXModelGroup;
@class NPVertexBuffer;
@class NPOpenGLRenderContext;

@interface TOScene : NPObject
{
    NPOpenGLRenderContext * renderContext;

    NPCamera * camera;

    NPSUXModel * surface;
    NPSUXModelLod * surfaceLod;
    NPSUXModelGroup * surfaceGroup;
    NPVertexBuffer * surfaceVBO;

    BOOL ready;
}

- (id) init;
- (id) initWithParent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (void) setRenderContext:(NPOpenGLRenderContext *)newRenderContext;

- (NPSUXModel *) surface;
- (NPSUXModelLod *) surfaceLod;
- (NPSUXModelGroup *) surfaceGroup;
- (NPVertexBuffer *) surfaceVBO;

- (void) setup;

- (void) update;
- (void) render;

@end
