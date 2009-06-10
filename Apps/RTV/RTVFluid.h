#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"


@interface RTVFluid : NPObject
{
    IVector2 * currentResolution;
    IVector2 * resolutionLastFrame;

    FMatrix4 * projection;
    FMatrix4 * identity;

    Float deltaX;
    Float deltaY;
    Float viscosity;

    id advection;
    id diffusion;
    id inputForce;
    id divergence;
    id pressure;

    id velocitySource;
    id velocityTarget;
    id velocityBiLerp;
    id inkSource;
    id inkTarget;
    id divergenceTarget;
    id pressureSource;
    id pressureTarget;

    id addVelocityAction;
    id addInkAction;

    id fluidRenderTargetConfiguration;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (void) clear;
- (void) setup;

- (IVector2) resolution;
- (Int32) width;
- (Int32) height;
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

- (void) setResolution:(IVector2)newResolution;

- (BOOL) loadFromPath:(NSString *)path;

- (void) activate;
- (void) deactivate;

- (void) update:(Float)frameTime;
- (void) render;

@end
