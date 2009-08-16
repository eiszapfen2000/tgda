#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"

@class NPVertexBuffer;
@class NPStateSet;
@class NPEffect;
@class NPRenderTargetConfiguration;
@class NPR2VBConfiguration;

@interface ODProjectedGridR2VB : NPObject
{
    IVector2 * projectedGridResolution;
    IVector2 * projectedGridResolutionLastFrame;

    NpState mode;

    Float basePlaneHeight;
    Float upperSurfaceBound;
    Float lowerSurfaceBound;
    FPlane * basePlane;

    NPVertexBuffer * nearPlaneGrid;
    NPVertexBuffer * projectedGrid;

    NPEffect * effect;
    CGparameter projectorIMVP;
    CGparameter deltaTime;

    NPRenderTargetConfiguration * renderTargetConfiguration;
    NPR2VBConfiguration * r2vbConfiguration;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (NpState) mode;
- (IVector2) projectedGridResolution;
- (Float) basePlaneHeight;
- (Float) lowerSurfaceBound;
- (Float) upperSurfaceBound;

- (void) setMode:(NpState)newMode;
- (void) setProjectedGridResolution:(IVector2)newProjectedGridResolution;
- (void) setBasePlaneHeight:(Float)newBasePlaneHeight;
- (void) setLowerSurfaceBound:(Float)newLowerSurfaceBound;
- (void) setUpperSurfaceBound:(Float)newUpperSurfaceBound;

- (void) update;
- (void) render;

@end
