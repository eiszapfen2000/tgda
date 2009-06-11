#import "Core/NPObject/NPObject.h"
#import "Core/Math/NpMath.h"
#import "Graphics/npgl.h"

@class NPTexture;
@class NPRenderTexture;

@interface RTVPressure : NPObject
{
    IVector2 * currentResolution;
    IVector2 * resolutionLastFrame;

    FVector2 * innerQuadUpperLeft;
    FVector2 * innerQuadLowerRight;
    FVector2 * pixelSize;

    id temporaryStorage;
    id pressureRenderTargetConfiguration;
    id pressureEffect;
    id gradientSubtractionEffect;

    CGparameter alpha;
    CGparameter rBeta;
    CGparameter rHalfDX;

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

- (void) computePressureFrom:(id)pressureSource
                          to:(id)pressureTarget
             usingDivergence:(id)divergence
                      deltaX:(Float)deltaX
                      deltaY:(Float)deltaY
                            ;

- (void) subtractGradientFromVelocity:(NPTexture *)velocitySource
                                   to:(NPRenderTexture *)velocityTarget
                        usingPressure:(NPTexture *)pressure
                               deltaX:(Float)deltaX
                                     ;


- (void) update:(Float)frameTime;
- (void) render;

@end
