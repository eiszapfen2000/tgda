#import "Core/NPObject/NPObject.h"
#import "Core/Math/NpMath.h"
#import "Graphics/npgl.h"

@interface RTVDivergence : NPObject
{
    IVector2 * currentResolution;
    IVector2 * resolutionLastFrame;

    id divergenceRenderTargetConfiguration;
    id divergenceEffect;
    CGparameter rHalfDX;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (IVector2) resolution;
- (void) setResolution:(IVector2)newResolution;

- (void) computeDivergenceFrom:(id)source to:(id)target;

- (void) update:(Float)frameTime;
- (void) render;

@end
