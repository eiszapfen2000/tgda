#import "Core/NPObject/NPObject.h"
#import "Core/Math/NpMath.h"
#import "Graphics/npgl.h"

@interface RTVInputForce : NPObject
{
    IVector2 * currentResolution;
    IVector2 * resolutionLastFrame;

    FVector2 * innerQuadUpperLeft;
    FVector2 * innerQuadLowerRight;
    FVector2 * pixelSize;

    id inputForceRenderTargetConfiguration;

    id inputEffect;
    CGparameter clickPosition;
    CGparameter radius;
    CGparameter scale;
    CGparameter color;

    id stateset;

    id leftClickAction;
    Float clickRadius;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (IVector2) resolution;
- (void) setResolution:(IVector2)newResolution;

- (void) addGaussianSplatToQuantity:(id)quantity
                        usingRadius:(Float)splatRadius
                              scale:(Float)scale
                              color:(FVector4 *)splatColor
                                   ;

- (void) update:(Float)frameTime;
- (void) render;

@end
