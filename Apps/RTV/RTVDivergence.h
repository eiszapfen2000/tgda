#import "Core/NPObject/NPObject.h"
#import "Core/Math/NpMath.h"
#import "Graphics/npgl.h"

@class NPTexture;
@class NPRenderTexture;

@interface RTVDivergence : NPObject
{
    IVector2 * currentResolution;
    IVector2 * resolutionLastFrame;

    FVector2 * innerQuadUpperLeft;
    FVector2 * innerQuadLowerRight;
    FVector2 * pixelSize;

    id divergenceRenderTargetConfiguration;
    id divergenceEffect;
    CGparameter rHalfDX;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (IVector2) resolution;
- (void) setResolution:(IVector2 *)newResolution;

- (void) computeDivergenceFrom:(NPTexture *)source
                            to:(NPRenderTexture *)target
                   usingDeltaX:(Float)deltaX
                              ;

- (void) update:(Float)frameTime;
- (void) render;

@end
