#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"

@interface TOCamera : NPObject
{
	FMatrix4 * view;
	FMatrix4 * projection;

    Quaternion * orientation;
    FVector3 * position;

	Float fov;
	Float nearPlane;
	Float farPlane;
	Float aspectRatio;

    Double yaw;
    Double pitch;
    Vector3 * forward;
}

- (id) init;
- (id) initWithParent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (void) reset;

- (FVector3 *) position;
- (void) setPosition:(FVector3 *)newPosition;
- (void) setFov:(Float)newFov;
- (void) setNearPlane:(Float)newNearPlane;
- (void) setFarPlane:(Float)newFarPlane;
- (void) setAspectRatio:(Float)newAspectRatio;

/*- (void) rotateX:(Double)degrees;
- (void) rotateY:(Double)degrees;
- (void) rotateZ:(Double)degrees;*/
- (void) cameraRotateUsingYaw:(Double)yawDegrees andPitch:(Double)pitchDegrees;
- (void) moveForward;
- (void) moveBackward;

- (void) updateProjection;
- (void) updateView;
- (void) update;

- (void) render;

@end
