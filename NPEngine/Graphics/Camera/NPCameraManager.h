#import "Core/NPObject/NPObject.h"

@class NPCamera;

@interface NPCameraManager : NPObject
{
    NSMutableArray * cameras;
    NPCamera * currentActiveCamera;
}

- (id) init;
- (id) initWithParent:(id <NPPObject> )newParent;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) setup;

- (NPCamera *) currentActiveCamera;
- (void) setCurrentActiveCamera:(NPCamera *)newCurrentActiveCamera;

- (NPCamera *) createCamera;

@end
