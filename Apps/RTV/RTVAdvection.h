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

    id temporaryStorage;
    id quantityBiLerp;
    id advectionRenderTargetConfiguration;

    id advectionEffect;
    CGparameter timestep;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (IVector2) resolution;
- (id) quantityBiLerp;
- (id) temporaryStorage;
- (void) setResolution:(IVector2)newResolution;


- (void) advectQuantityFrom:(NPRenderTexture *)quantitySource
                         to:(NPRenderTexture *)quantityTarget
              usingVelocity:(NPRenderTexture *)velocity
                  frameTime:(Float)frameTime
        arbitraryBoundaries:(BOOL)arbitraryBoundaries
          andScaleAndOffset:(NPRenderTexture *)scaleAndOffset
                           ;


- (void) normalQuantityAdvectionFrom:(NPRenderTexture *)quantitySource
                                  to:(NPRenderTexture *)quantityTarget
                       usingVelocity:(NPRenderTexture *)velocity
                           frameTime:(Float)frameTime
                                    ;

- (void) arbitraryBoundariesAdvectionFrom:(NPRenderTexture *)quantitySource
                                       to:(NPRenderTexture *)quantityTarget
                            usingVelocity:(NPRenderTexture *)velocity
                                frameTime:(Float)frameTime
                        andScaleAndOffset:(NPRenderTexture *)scaleAndOffset
                                         ;

//THIS IS A HACK, THIS SHOULD NOT BE HERE
- (void) updateQuantityBoundariesFrom:(NPRenderTexture *)quantitySource
                                   to:(NPRenderTexture *)quantityTarget
                  arbitraryBoundaries:(BOOL)arbitraryBoundaries
                    andScaleAndOffset:(NPRenderTexture *)scaleAndOffset
                                     ;

- (void) update:(Float)frameTime;
- (void) render;

@end
