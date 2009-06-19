#import "Core/NPObject/NPObject.h"

@interface RTVScene : NPObject
{
    id font;
    id fullscreenEffect;

    id menu;

    id fluid;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (BOOL) loadFromPath:(NSString *)path;

- (void) activate;
- (void) deactivate;

- (void) update:(Float)frameTime;
- (void) render;

@end
