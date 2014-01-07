#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"

@class NPVertexBuffer;

#define NEARPLANE_LOWERLEFT    0
#define NEARPLANE_LOWERRIGHT   1
#define NEARPLANE_UPPERRIGHT   2
#define NEARPLANE_UPPERLEFT    3
#define FARPLANE_LOWERLEFT     4
#define FARPLANE_LOWERRIGHT    5
#define FARPLANE_UPPERRIGHT    6
#define FARPLANE_UPPERLEFT     7

@interface ODFrustum : NPObject
{
    NPVertexBuffer * frustumGeometry;
    Float * frustumVertices;
    Int   * frustumIndices;

    FVector3 * frustumCornerPositions[8];

    Float nearPlaneHeight;
    Float nearPlaneWidth;
    Float farPlaneHeight;
    Float farPlaneWidth;

    Float nearPlaneHalfHeight;
    Float nearPlaneHalfWidth;
    Float farPlaneHalfHeight;
    Float farPlaneHalfWidth;

    FVector3 * farPlaneHalfWidthV;
    FVector3 * nearPlaneHalfWidthV;
    FVector3 * farPlaneHalfHeightV;
    FVector3 * nearPlaneHalfHeightV;

    FVector3 * positionToNearPlaneCenter;
    FVector3 * positionToFarPlaneCenter;

    FVector3 * forward;
    FVector3 * up;
    FVector3 * right;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (FVector3 **) frustumCornerPositions;
- (Float) nearPlaneHeight;
- (Float) nearPlaneWidth;
- (Float) farPlaneHeight;
- (Float) farPlaneWidth;

- (void) updateWithPosition:(FVector3 *)position
                orientation:(FQuaternion *)orientation
                        fov:(Float)fov
                  nearPlane:(Float)nearPlane
                   farPlane:(Float)farPlane
                aspectRatio:(Float)aspectRatio;
- (void) render;

@end
