#import "Core/NPObject/NPObject.h"

@interface RTVDiffusion : NPObject
{
    id diffusionEffect;
    id diffusionRenderTargetConfiguration;

    CGparameter alpha;
    CGparameter rBeta;

    Int32 numberOfIterations;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (void) diffuseQuantityFrom:(id)quantitySource to:(id)quantityTarget;

@end
