#import "Core/NPObject/NPObject.h"
#import "Core/Math/NpMath.h"
#import "Graphics/npgl.h"

@class NPTexture;
@class NPRenderTexture;

@interface RTVArbitraryBoundaries : NPObject
{
    IVector2 * currentResolution;
    IVector2 * resolutionLastFrame;

    FVector2 * innerQuadUpperLeft;
    FVector2 * innerQuadLowerRight;
    FVector2 * pixelSize;

    id velocityScaleAndOffset;
    id pressureScaleAndOffset;

    id arbitraryBoundariesEffect;
    id arbitraryBoundariesRenderTargetConfiguration;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (void) setupScaleAndOffsetTextures;

- (IVector2) resolution;
- (void) setResolution:(IVector2)newResolution;

- (void) update:(Float)frameTime;
- (void) render;

@end
