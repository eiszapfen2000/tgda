#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"

@interface FCamera : NPObject
{
	FMatrix4 * view;
	FMatrix4 * projection;

    FQuaternion * orientation;
    FVector3 * position;

	Float fov;
	Float nearPlane;
	Float farPlane;
	Float aspectRatio;

    Float yaw;
    Float pitch;
    FVector3 * forward;

    id forwardMovementAction;
    id backwardMovementAction;
    id strafeLeftAction;
    id strafeRightAction;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (void) reset;

- (FVector3 *) position;
- (void) setPosition:(FVector3 *)newPosition;

- (FMatrix4 *) projection;

- (Float) fov;
- (void)  setFov:(Float)newFov;
- (Float) nearPlane;
- (void)  setNearPlane:(Float)newNearPlane;
- (Float) farPlane;
- (void)  setFarPlane:(Float)newFarPlane;
- (Float) aspectRatio;
- (void)  setAspectRatio:(Float)newAspectRatio;

- (void) cameraRotateUsingYaw:(Float)yawDegrees andPitch:(Float)pitchDegrees;
- (void) moveForward:(Float)frameTime;
- (void) moveBackward:(Float)frameTime;
- (void) moveLeft:(Float)frameTime;
- (void) moveRight:(Float)frameTime;

- (void) updateProjection;
- (void) updateView;
- (void) update:(Float)frameTime;

- (void) render;

@end
