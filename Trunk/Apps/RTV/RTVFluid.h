#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"


@interface RTVFluid : NPObject
{
    IVector2 * currentResolution;
    IVector2 * resolutionLastFrame;
    FVector2 * pixelSize;

    FVector4 * inkColor;
    Float inputRadius;

    Float deltaX;
    Float deltaY;
    Float viscosity;

    id advection;
    id diffusion;
    id inputForce;
    id divergence;
    id pressure;
    id arbitraryBoundaries;

    id velocitySource;
    id velocityTarget;
    id velocityBiLerp;
    id inkSource;
    id inkTarget;
    id divergenceTarget;
    id pressureSource;
    id pressureTarget;
    id arbitraryBoundariesPaint;
    id arbitraryBoundariesVelocity;
    id arbitraryBoundariesPressure;

    id addVelocityAction;
    id addInkAction;
    id addBoundaryAction;

    id effect;
    id fluidRenderTargetConfiguration;

    BOOL useArbitraryBoundaries;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (IVector2) resolution;
- (Int32) width;
- (Int32) height;
- (BOOL) useArbitraryBoundaries;
- (id) advection;
- (id) diffusion;
- (id) inputForce;
- (id) divergence;
- (id) pressure;

- (id) velocitySource;
- (id) velocityTarget;
- (id) velocityBiLerp;
- (id) inkSource;
- (id) inkTarget;
- (id) divergenceTarget;
- (id) pressureSource;
- (id) pressureTarget;
- (id) arbitraryBoundariesPaint;
- (id) arbitraryBoundariesVelocity;
- (id) arbitraryBoundariesPressure;

- (void) setArbitraryBoundaries:(BOOL)newArbitraryBoundaries;
- (void) setInkColor:(FVector4)newInkColor;
- (void) setInputRadius:(Float)newInputRadius;
- (void) setResolution:(IVector2 *)newResolution;
- (void) setViscosity:(Float)newViscosity;

- (BOOL) loadFromPath:(NSString *)path;

- (void) update:(Float)frameTime;
- (void) render;

@end
