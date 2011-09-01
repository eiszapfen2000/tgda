#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "ODPEntity.h"

@class NPInputAction;
@class ODProjector;

@interface ODCamera : NPObject < ODPEntity >
{
	FMatrix4 view;
	FMatrix4 projection;
    FQuaternion orientation;
    FVector3 position;

	float fov;
	float nearPlane;
	float farPlane;
	float aspectRatio;

    float yaw;
    float pitch;
    FVector3 forward;

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

- (void) reset;

- (float) fov;
- (float) aspectRatio;
- (float) nearPlane;
- (float) farPlane;
- (FVector3) forward;
- (FVector3) position;
- (FQuaternion) orientation;
- (FMatrix4 *) view;
- (FMatrix4 *) projection;
- (BOOL) inputLocked;

- (void) setFov:(const float)newFov;
- (void) setNearPlane:(const float)newNearPlane;
- (void) setFarPlane:(const float)newFarPlane;
- (void) setAspectRatio:(const float)newAspectRatio;
- (void) setPosition:(const FVector3)newPosition;
- (void) setOrientation:(const FQuaternion)newOrientation;

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
