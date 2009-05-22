#import "Core/NPObject/NPObject.h"

@interface RTVFluid : NPObject
{
    IVector2 * currentResolution;
    IVector2 * resolutionLastFrame;

    id advection;
    id diffusion;
    id inputForce;
    id divergence;

    id velocitySource;
    id velocityTarget;
    id ink;
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
- (id) velocityTarget;

- (void) setResolution:(IVector2)newResolution;

- (BOOL) loadFromPath:(NSString *)path;

- (void) activate;
- (void) deactivate;

- (void) update:(Float)frameTime;
- (void) render;

@end
