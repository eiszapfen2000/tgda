#import "Core/NPObject/NPObject.h"
#import "Graphics/npgl.h"

@interface RTVInputForce : NPObject
{
    id inputEffect;
    id inputForceRenderTargetConfiguration;

    id leftClickAction;
    id stateSet;

    CGparameter clickPosition;
    CGparameter radius;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (void) update:(Float)frameTime;
- (void) render;

@end
