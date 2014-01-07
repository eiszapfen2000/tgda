#import "Core/NPObject/NPObject.h"

@class NPCamera;

@interface NPCameraManager : NPObject
{
    NSMutableArray * cameras;
    id currentActiveCamera;
}

- (id) init;
- (id) initWithParent:(id <NPPObject> )newParent;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) setup;

- (id) currentActiveCamera;
- (void) setCurrentActiveCamera:(id)newCurrentActiveCamera;

- (id) createCamera;

@end
