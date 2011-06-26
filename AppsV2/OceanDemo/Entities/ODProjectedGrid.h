#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "ODPEntity.h"

@class NPCPUBuffer;
@class NPCPUVertexArray;

@interface ODProjectedGrid : NPObject < ODPEntity >
{
    IVector2 resolutionLastFrame;
    IVector2 resolution;

    FPlane basePlane;

    FVertex4 * nearPlanePostProjectionPositions;
    FVertex4 * worldSpacePositions;
    uint16_t * indices;

    NPCPUBuffer * vertexStream;
    NPCPUBuffer * indexStream;
    NPCPUVertexArray * vertexArray;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

@end

