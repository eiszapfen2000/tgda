#import "Core/NPObject/NPObject.h"

@interface RTVDiffusion : NPObject
{
    IVector2 * currentResolution;
    IVector2 * resolutionLastFrame;

    FVector2 * innerQuadUpperLeft;
    FVector2 * innerQuadLowerRight;
    FVector2 * pixelSize;

    id diffusionRenderTargetConfiguration;

    id diffusionEffect;
    CGparameter alpha;
    CGparameter rBeta;

    Int32 numberOfIterations;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (Int32) numberOfIterations;
- (IVector2) resolution;

- (void) setNumberOfIterations:(Int32)newNumberOfIterations;
- (void) setResolution:(IVector2)newResolution;

- (void) diffuseQuantityFrom:(id)quantitySource to:(id)quantityTarget;

- (void) update:(Float)frameTime;
- (void) render;

@end
