#import "Core/NPObject/NPObject.h"

@class NPCamera;
@class NPModel;

@interface TOScene : NPObject
{
    NPCamera * camera;
    NPModel * surface;

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
