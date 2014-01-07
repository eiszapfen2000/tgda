#import "Core/NPObject/NPObject.h"

@class NPCamera;
@class NPSUXModel;
@class NPSUXModelLod;
@class NPSUXModelGroup;
@class NPVertexBuffer;
@class NPOpenGLRenderContext;
@class TOCamera;

@interface TOScene : NPObject
{
    NPOpenGLRenderContext * renderContext;

    //NPCamera * camera;
    TOCamera * camera;

    NPSUXModel * surface;
    NPSUXModelLod * surfaceLod;
    NPSUXModelGroup * surfaceGroup;
    NPVertexBuffer * surfaceVBO;

    NPVertexBuffer * triangleVBO;

    NPSUXModel * testCamera;

    BOOL ready;
}

- (id) init;
- (id) initWithParent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

//- (void) setRenderContext:(NPOpenGLRenderContext *)newRenderContext;

- (TOCamera *) camera;
- (NPSUXModel *) surface;
- (NPSUXModelLod *) surfaceLod;
- (NPSUXModelGroup *) surfaceGroup;
- (NPVertexBuffer *) surfaceVBO;

- (void) setup;

- (void) update;
- (void) render;

@end
