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
    float yaw;
    float pitch;

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
- (float) yaw;
- (float) pitch;
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
- (void) setYaw:(const float)newYaw;
- (void) setPitch:(const float)newPitch;

- (void) lockInput;
- (void) unlockInput;

- (void) cameraRotateUsingYaw:(const float)yawDegrees andPitch:(const float)pitchDegrees;
- (void) moveForward:(const float)frameTime;
- (void) moveBackward:(const float)frameTime;
- (void) moveLeft:(const float)frameTime;
- (void) moveRight:(const float)frameTime;

- (void) updateProjection;
- (void) updateView;

@end
