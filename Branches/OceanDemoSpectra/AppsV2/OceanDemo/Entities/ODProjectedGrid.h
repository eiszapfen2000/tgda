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

@interface ODProjectedGrid : NPObject
{
    // resolution
    IVector2 resolutionLastFrame;
    IVector2 resolution;
    // the plane we want project onto, y = 0
    Plane basePlane;
    // vertices on the near plane in post projection space
    FVertex2 * nearPlanePostProjectionPositions;
    // mesh indices for rendering
    uint16_t * gridIndices;
    // the projector we are connected to
    ODProjector * projector;
    // buffers and vertex array for grid based rendering
    NPBufferObject * gridVertexStream;
    NPBufferObject * gridIndexStream;
    NPVertexArray  * gridVertexArray;
    // query
    GLuint query;
    // transform target buffer
    NPBufferObject * transformedVertexStream;
    NPBufferObject * transformedNonDisplacedVertexStream;
    NPVertexArray * transformTarget;
    //
    Vector2 vertexStep;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (IVector2) resolution;
- (Vector2)  vertexStep;
- (void) setResolution:(const IVector2)newResolution;
- (void) setProjector:(ODProjector *)newProjector;

- (void) update:(const double)frameTime;

- (void) renderTFTransform;
- (void) renderTFFeedback;

@end

