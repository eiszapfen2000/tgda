#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"

@class NPVertexBuffer;
@class NPStateSet;

#define ODSURFACE_NEARPLANE 0
#define ODSURFACE_FARPLANE  1

@interface ODSurface : NPObject
{
    IVector2 * resolution;
    IVector2 * currentResolution;
    IVector2 * defaultResolution;

    Float basePlaneHeight;
    Float upperSurfaceBound;
    Float lowerSurfaceBound;
    FPlane * basePlane;

    NPStateSet * states;
    NPVertexBuffer * surfaceGeometry;

    Int * indices;
    Float * nearPlaneWorldSpacePositions;
    Float * nearPlanePostProjectionPositions;
    Float * farPlaneWorldSpacePositions;
    Float * worldSpacePositions;
}

- (id) init;
- (id) initWithParent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent resolution:(IVector2 *)newResolution ;
- (void) dealloc;

- (IVector2 *) resolution;
- (void) setResolution:(IVector2 *)newResolution;
- (void) setXAxisResolution:(Int)newX;
- (void) setZAxisResolution:(Int)newZ;

- (IVector2 *) defaultResolution;
- (void) setDefaultResolution:(IVector2 *)newDefaultResolution;
- (void) setDefaultXAxisResolution:(Int)newX;
- (void) setDefaultZAxisResolution:(Int)newZ;

- (Float) basePlaneHeight;
- (void)  setBasePlaneHeight:(Float)newBasePlaneHeight;
- (Float) upperSurfaceBound;
- (void)  setUpperSurfaceBound:(Float)newUpperSurfaceBound;
- (Float) lowerSurfaceBound;
- (void)  setLowerSurfaceBound:(Float)newLowerSurfaceBound;

- (void) update;
- (void) render;

@end
