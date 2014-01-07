#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"

#define NEARPLANE_LOWERLEFT    0
#define NEARPLANE_LOWERRIGHT   1
#define NEARPLANE_UPPERRIGHT   2
#define NEARPLANE_UPPERLEFT    3
#define FARPLANE_LOWERLEFT     4
#define FARPLANE_LOWERRIGHT    5
#define FARPLANE_UPPERRIGHT    6
#define FARPLANE_UPPERLEFT     7

#define FRUSTUM_FRONT   0
#define FRUSTUM_BACK    1
#define FRUSTUM_TOP     2
#define FRUSTUM_BOTTOM  3
#define FRUSTUM_LEFT    4
#define FRUSTUM_RIGHT   5 

@class NSData;
@class NPEffect;
@class NPEffectVariableFloat4;
@class NPCPUBuffer;
@class NPCPUVertexArray;

@interface ODFrustum : NPObject
{
    // indcies to render frustum quads
    uint16_t frustumFaceIndices[24];
    // indices to render frustum as lines
    uint16_t frustumLineIndices[24];
    // frustum world space vertex positions
    FVertex3 frustumCornerPositions[8];

    NPCPUBuffer * vertexStream;
    NPCPUBuffer * facesIndexStream;
    NPCPUBuffer * linesIndexStream;
    NPCPUVertexArray * facesVertexArray;
    NPCPUVertexArray * linesVertexArray;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (void) updateWithPosition:(const Vector3)position
                orientation:(const Quaternion)orientation
                        fov:(const double)fov
                  nearPlane:(const double)nearPlane
                   farPlane:(const double)farPlane
                aspectRatio:(const double)aspectRatio
                           ;

- (void) render;

@end
