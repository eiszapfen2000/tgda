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
- (FVector3 *) forward;
- (FVector3 *) position;
- (FMatrix4 *) view;
- (FMatrix4 *) projection;

- (void) setFov:(float)newFov;
- (void) setNearPlane:(float)newNearPlane;
- (void) setFarPlane:(float)newFarPlane;
- (void) setAspectRatio:(float)newAspectRatio;
- (void) setPosition:(FVector3 *)newPosition;

- (void) cameraRotateUsingYaw:(float)yawDegrees andPitch:(float)pitchDegrees;
- (void) moveForward:(float)frameTime;
- (void) moveBackward:(float)frameTime;
- (void) moveLeft:(float)frameTime;
- (void) moveRight:(float)frameTime;

- (void) updateProjection;
- (void) updateView;

@end
