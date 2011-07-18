#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "ODPEntity.h"

@class NPCPUBuffer;
@class NPCPUVertexArray;
@class ODProjector;
@class NPEffect;
@class NPEffectVariableFloat4;

typedef enum ODProjectedGridRenderMode
{
    ProjectedGridCPURaycasting = 0,
    ProjectedGridCPUInterpolation = 1,
    ProjectedGridGPUInterpolation = 2
}
ODProjectedGridRenderMode;

@interface ODProjectedGrid : NPObject < ODPEntity >
{
    IVector2 resolutionLastFrame;
    IVector2 resolution;

    FPlane basePlane;

    FVertex4 * nearPlanePostProjectionPositions;
    FVertex4 * worldSpacePositions;
    uint16_t * indices;

    FVertex4 boundaryVertices[4];

    ODProjector * projector;

    ODProjectedGridRenderMode renderMode;

    NPCPUBuffer * vertexStream;
    NPCPUBuffer * indexStream;
    NPCPUVertexArray * vertexArray;

    NPEffect * effect;
    NPEffectVariableFloat4 * color;
    FVector4 gridColor;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (ODProjectedGridRenderMode) renderMode;
- (IVector2) resolution;
- (void) setResolution:(const IVector2)newResolution;
- (void) setRenderMode:(const ODProjectedGridRenderMode)newRenderMode;
- (void) setProjector:(ODProjector *)newProjector;

@end

