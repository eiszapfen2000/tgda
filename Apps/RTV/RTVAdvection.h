#import "Core/NPObject/NPObject.h"
#import "Core/Math/NpMath.h"
#import "Graphics/npgl.h"

@class NPTexture;
@class NPRenderTexture;

@interface RTVAdvection : NPObject
{
    IVector2 * currentResolution;
    IVector2 * resolutionLastFrame;

    FVector2 * innerQuadUpperLeft;
    FVector2 * innerQuadLowerRight;
    FVector2 * pixelSize;

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
- (id) temporaryStorage;

- (void) setResolution:(IVector2)newResolution;

- (void) advectQuantityFrom:(NPTexture *)quantitySource
                         to:(NPRenderTexture *)quantityTarget
              usingVelocity:(NPTexture *)velocity
               andFrameTime:(Float)frameTime
                           ;

- (void) update:(Float)frameTime;
- (void) render;

@end
