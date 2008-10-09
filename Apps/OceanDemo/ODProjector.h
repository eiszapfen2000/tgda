#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"

@class NPVertexBuffer;
@class ODFrustum;

#define NEARPLANE_LOWERLEFT    0
#define NEARPLANE_LOWERRIGHT   1
#define NEARPLANE_UPPERRIGHT   2
#define NEARPLANE_UPPERLEFT    3
#define FARPLANE_LOWERLEFT     4
#define FARPLANE_LOWERRIGHT    5
#define FARPLANE_UPPERRIGHT    6
#define FARPLANE_UPPERLEFT     7

@interface ODProjector : NPObject
{
	FMatrix4 * view;
    FMatrix4 * projection;
    FMatrix4 * viewProjection;
    FMatrix4 * inverseViewProjection;

    FQuaternion * orientation;
    FVector3 * position;

    Float yaw;
    Float pitch;
    FVector3 * forward;
    FVector3 * right;
    FVector3 * up;

    Float fov;
    Float nearPlane;
    Float farPlane;
    Float aspectRatio;

    BOOL renderFrustum;
    ODFrustum * frustum;
}

- (id) init;
- (id) initWithParent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (void) reset;

- (FVector3 *) position;
- (void) setPosition:(FVector3 *)newPosition;

- (void) setRenderFrustum:(BOOL)newRenderFrustum;

- (ODFrustum *) frustum;
- (FMatrix4 *) projection;
- (FMatrix4 *) viewProjection;
- (FMatrix4 *) inverseViewProjection;

- (void) cameraRotateUsingYaw:(Float)yawDegrees andPitch:(Float)pitchDegrees;
- (void) moveForward;
- (void) moveBackward;

- (void) updateProjection;
- (void) updateView;
- (void) update;

- (void) render;

@end
