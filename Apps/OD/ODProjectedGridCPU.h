#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"

@class NPVertexBuffer;
@class NPStateSet;

#define ODSURFACE_NEARPLANE 0
#define ODSURFACE_FARPLANE  1

@interface ODProjectedGridCPU : NPObject
{
    IVector2 * projectedGridResolution;
    IVector2 * projectedGridResolutionLastFrame;

    Float basePlaneHeight;
    Float upperSurfaceBound;
    Float lowerSurfaceBound;
    FPlane * basePlane;

    NPVertexBuffer * surfaceGeometry;

    Int * indices;
    Float * nearPlaneWorldSpacePositions;
    Float * nearPlanePostProjectionPositions;
    Float * farPlaneWorldSpacePositions;
    Float * worldSpacePositions;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (IVector2) projectedGridResolution;
- (Float) basePlaneHeight;
- (Float) lowerSurfaceBound;
- (Float) upperSurfaceBound;

- (void) setProjectedGridResolution:(IVector2)newProjectedGridResolution;
- (void) setBasePlaneHeight:(Float)newBasePlaneHeight;
- (void) setLowerSurfaceBound:(Float)newLowerSurfaceBound;
- (void) setUpperSurfaceBound:(Float)newUpperSurfaceBound;

- (void) update;
- (void) render;

@end
