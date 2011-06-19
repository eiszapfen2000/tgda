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
@class NPCPUBuffer;
@class NPCPUVertexArray;

@interface ODFrustum : NPObject
{
    uint16_t frustumFaceIndices[24];
    uint16_t defaultFaceIndices[24];
    uint16_t frustumLineIndices[24];

    FVertex3 frustumCornerPositions[8];
    FVertex3 frustumFaceVertices[8];
    FVertex3 frustumLineVertices[8];

    NSData * vertexData;
    NSData * indexData;
    NPCPUBuffer * vertexStream;
    NPCPUBuffer * indexStream;
    NPCPUVertexArray * vertexArray;

    NPEffect * effect;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (void) updateWithPosition:(const FVector3)position
                orientation:(const FQuaternion)orientation
                        fov:(const float)fov
                  nearPlane:(const float)nearPlane
                   farPlane:(const float)farPlane
                aspectRatio:(const float)aspectRatio
                           ;

- (void) render;

@end
