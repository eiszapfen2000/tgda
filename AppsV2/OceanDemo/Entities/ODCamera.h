#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "ODPEntity.h"

@class NPInputAction;
@class ODProjector;

@interface ODCamera : NPObject < ODPEntity >
{
    Matrix4 view;
    Matrix4 projection;
    Matrix4 inverseViewProjection;
    Quaternion orientation;
    Vector3 position;
    Vector3 forward;
	float fov;
	float nearPlane;
	float farPlane;
	float aspectRatio;
    double yaw;
    double pitch;

    BOOL inputLocked;
    NPInputAction * leftClickAction;
    NPInputAction * forwardMovementAction;
    NPInputAction * backwardMovementAction;
    NPInputAction * strafeLeftAction;
    NPInputAction * strafeRightAction;
    NPInputAction * wheelDownAction;
    NPInputAction * wheelUpAction;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (float) fov;
- (float) aspectRatio;
- (float) nearPlane;
- (float) farPlane;
- (Vector3) forward;
- (Vector3) position;
- (Quaternion) orientation;
- (double) yaw;
- (double) pitch;
- (Matrix4 *) view;
- (Matrix4 *) projection;
- (Matrix4 *) inverseViewProjection;
- (BOOL) inputLocked;

- (void) setFov:(const float)newFov;
- (void) setNearPlane:(const float)newNearPlane;
- (void) setFarPlane:(const float)newFarPlane;
- (void) setAspectRatio:(const float)newAspectRatio;
- (void) setPosition:(const Vector3)newPosition;
- (void) setOrientation:(const Quaternion)newOrientation;
- (void) setYaw:(const double)newYaw;
- (void) setPitch:(const double)newPitch;

- (void) lockInput;
- (void) unlockInput;

- (void) cameraRotateUsingYaw:(const double)yawDegrees andPitch:(const double)pitchDegrees;
- (void) moveForward:(const double)frameTime;
- (void) moveBackward:(const double)frameTime;
- (void) moveLeft:(const double)frameTime;
- (void) moveRight:(const double)frameTime;

- (void) updateProjection;
- (void) updateView;

@end
