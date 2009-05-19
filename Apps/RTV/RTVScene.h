#import "Core/NPObject/NPObject.h"

@interface RTVScene : NPObject
{
    id advection;
    id diffusion;
    id inputForce;
    id fullscreenEffect;

    id componentSource;
    id componentTarget;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (id) advection;
- (id) inputForce;

- (BOOL) loadFromPath:(NSString *)path;

- (void) activate;
- (void) deactivate;

- (void) update:(Float)frameTime;
- (void) render;

@end
