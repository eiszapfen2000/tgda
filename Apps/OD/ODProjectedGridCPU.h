#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"

@class NPVertexBuffer;
@class NPStateSet;

#define OD_PROJECT_ENTIRE_MESH_ON_CPU               0
#define OD_PROJECT_USING_INTERPOLATION_ON_CPU       1
#define OD_PROJECT_CPU_CORNERS_GPU_INTERPOLATION    2

@interface ODProjectedGridCPU : NPObject
{
    IVector2 * projectedGridResolution;
    IVector2 * projectedGridResolutionLastFrame;

    NpState mode;

    Float basePlaneHeight;
    Float upperSurfaceBound;
    Float lowerSurfaceBound;
    FPlane * basePlane;

    NPVertexBuffer * surfaceGeometry;
    Float * nearPlanePostProjectionPositions;
    Float * worldSpacePositions;
    Float * normals;
    Float * texCoords;
    Int * indices;

    id effect;
    CGparameter lowerLeftCornerParameter;
    CGparameter lowerRightCornerParameter;
    CGparameter upperRightCornerParameter;
    CGparameter upperLeftCornerParameter;
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
