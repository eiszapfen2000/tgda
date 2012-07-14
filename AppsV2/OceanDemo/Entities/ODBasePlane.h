#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "ODPEntity.h"

@class NPCPUBuffer;
@class NPCPUVertexArray;
@class ODCamera;

@interface ODBasePlane : NPObject
{
    // the camera we get the inverse viewprojection matrix from
    ODCamera * camera;
    // the plane we want project onto, y = 0
    FPlane basePlane;
    // near plane corner vertices projected onto basePlane
    FVertex3 * cornerVertices;
    uint16_t * cornerIndices;
    // buffer and vertex array for base plane rendering
    NPCPUBuffer * cornerVertexStream;
    NPCPUBuffer * cornerIndexStream;
    NPCPUVertexArray * cornerVertexArray;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (void) setCamera:(ODCamera *)newCamera;

- (void) update:(const double)frameTime;
- (void) render;

@end

