#import "Core/NPObject/NPObject.h"

@interface RTVAdvection : NPObject
{
    id velocitySource;
    id velocityTarget;
    id temporaryStorage;
    id advectionRenderTargetConfiguration;
    id advectionEffect;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (id) velocitySource;
- (id) velocityTarget;
- (id) advectionEffect;

- (void) advectQuantityFrom:(id)quantitySource to:(id)quantityTarget;
- (void) swapVelocityRenderTextures;

- (void) update:(Float)frameTime;
- (void) render;

@end
