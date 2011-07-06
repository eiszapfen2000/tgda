#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "ODPEntity.h"

@class NPCPUBuffer;
@class NPCPUVertexArray;
@class ODProjector;

@interface ODProjectedGrid : NPObject < ODPEntity >
{
    IVector2 resolutionLastFrame;
    IVector2 resolution;

    FPlane basePlane;

    FVertex4 * nearPlanePostProjectionPositions;
    FVertex4 * worldSpacePositions;
    uint16_t * indices;

    ODProjector * projector;

    NPCPUBuffer * vertexStream;
    NPCPUBuffer * indexStream;
    NPCPUVertexArray * vertexArray;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (IVector2) resolution;
- (void) setResolution:(const IVector2)newResolution;
- (void) setProjector:(ODProjector *)newProjector;

@end

