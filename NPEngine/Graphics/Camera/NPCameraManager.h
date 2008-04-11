#import "Core/NPObject/NPObject.h"

@class NPCamera;

@interface NPCameraManager : NPObject
{
    NSMutableArray * cameras;
    NPCamera * currentActiveCamera;
}

- (id) init;
- (id) initWithParent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (void) setup;

- (NPCamera *) currentActiveCamera;
- (void) setCurrentActiveCamera:(NPCamera *)newCurrentActiveCamera;

- (NPCamera *) createCamera;

@end
