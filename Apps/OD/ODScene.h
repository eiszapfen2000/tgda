#import "Core/NPObject/NPObject.h"

@interface ODScene : NPObject
{
    NSMutableArray * entities;

    id camera;
    id projector;

    id font;
    id ocean;

    id fullscreenEffect;
    id texture;

    id menu;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (BOOL) loadFromPath:(NSString *)path;

- (id) camera;
- (id) projector;

- (void) activate;
- (void) deactivate;

- (void) update:(Float)frameTime;
- (void) render;

@end
