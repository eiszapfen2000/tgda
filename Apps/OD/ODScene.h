#import "Core/NPObject/NPObject.h"

@class ODCamera;

@interface ODScene : NPObject
{
    ODCamera * camera;
    id projector;
    id skybox;
    id entities;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (BOOL) loadFromPath:(NSString *)path;

- (void) activate;
- (void) deactivate;

- (id) camera;
- (id) projector;

- (void) update;
- (void) render;

@end
