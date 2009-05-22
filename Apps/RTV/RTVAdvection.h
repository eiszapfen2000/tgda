#import "Core/NPObject/NPObject.h"
#import "Core/Math/NpMath.h"
#import "Graphics/npgl.h"

@interface RTVAdvection : NPObject
{
    IVector2 * currentResolution;
    IVector2 * resolutionLastFrame;
    FVector2 * offsetVector;

    id advectionRenderTargetConfiguration;
    id temporaryStorage;

    id advectionEffect;
    CGparameter timestep;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (IVector2) resolution;
- (void) setResolution:(IVector2)newResolution;

- (void) advectQuantityFrom:(id)quantitySource
                         to:(id)quantityTarget
              usingVelocity:(id)velocity
                           ;

- (void) update:(Float)frameTime;
- (void) render;

@end
