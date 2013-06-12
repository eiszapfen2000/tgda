#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "ODPEntity.h"

@class NPBufferObject;
@class NPVertexArray;
@class NPCPUBuffer;
@class NPCPUVertexArray;
@class ODProjector;
@class NPEffect;
@class NPEffectTechnique;
@class NPEffectVariableFloat4;
@class NPTexture2D;

typedef enum ODProjectedGridRenderMode
{
    ProjectedGridCPURaycasting = 0,
    ProjectedGridCPUInterpolation = 1,
    ProjectedGridGPUInterpolation = 2
}
ODProjectedGridRenderMode;

@interface ODProjectedGrid : NPObject// < ODPEntity >
{
    // resolution
    IVector2 resolutionLastFrame;
    IVector2 resolution;
    // the plane we want project onto, y = 0
    Plane basePlane;
    // vertices on the near plane in post projection space
    FVertex2 * nearPlanePostProjectionPositions;
    // vertices projected from near plane onto basePlane
    FVertex3 * worldSpacePositions;
    // near plane corner vertices projected onto basePlane
    FVertex3 * cornerVertices;
    // mesh indices for rendering
    uint16_t * gridIndices;
    uint16_t * cornerIndices;
    // the projector we are connected to
    ODProjector * projector;
    // rendering mode
    ODProjectedGridRenderMode renderMode;
    // buffers and vertex array for grid based rendering
    NPCPUBuffer * gridVertexStream;
    NPCPUBuffer * gridIndexStream;
    NPCPUVertexArray * gridVertexArray;
    // buffer and vertex array for GPU interpolation based rendering
    NPCPUBuffer * cornerVertexStream;
    NPCPUBuffer * cornerIndexStream;
    NPCPUVertexArray * cornerVertexArray;
    // query
    GLuint query;
    // transform target buffer
    NPBufferObject * transformedVertexStream;
    NPVertexArray * transformTarget;
    // effect
    NPEffect * effect;
    NPEffectTechnique* transformTechnique;
    NPEffectTechnique* feedbackTechnique;
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

- (void) update:(const double)frameTime;
- (void) render:(NPTexture2D *)heights;

@end

