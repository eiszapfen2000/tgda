#import "Core/NPObject/NPObject.h"

@class NPCamera;
@class NPSUXModel;
@class NPSUXModelLod;
@class NPSUXModelGroup;
@class NPVertexBuffer;

@interface TOScene : NPObject
{
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

- (void) setup;

- (void) update;
- (void) render;

@end
