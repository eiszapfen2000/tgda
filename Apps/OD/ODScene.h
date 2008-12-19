#import "Core/NPObject/NPObject.h"

@interface ODScene : NPObject
{
    id camera;
    id projector;
    id skybox;
    id entities;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (BOOL) loadFromPath:(NSString *)path;

- (void) setup;

- (id) camera;
- (id) projector;

- (void) update;
- (void) render;

@end
