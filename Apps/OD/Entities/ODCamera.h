#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "ODPEntity.h"

@interface ODCamera : NPObject < ODPEntity >
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

    id leftClickAction;
    id forwardMovementAction;
    id backwardMovementAction;
    id strafeLeftAction;
    id strafeRightAction;
    id wheelDownAction;
    id wheelUpAction;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (void) reset;

- (Float) fov;
- (Float) aspectRatio;
- (Float) nearPlane;
- (Float) farPlane;
- (FVector3 *) forward;
- (FVector3 *) position;
- (FMatrix4 *) view;
- (FMatrix4 *) projection;

- (void) setFov:(Float)newFov;
- (void) setNearPlane:(Float)newNearPlane;
- (void) setFarPlane:(Float)newFarPlane;
- (void) setAspectRatio:(Float)newAspectRatio;
- (void) setPosition:(FVector3 *)newPosition;

- (void) cameraRotateUsingYaw:(Float)yawDegrees andPitch:(Float)pitchDegrees;
- (void) moveForward:(Float)frameTime;
- (void) moveBackward:(Float)frameTime;
- (void) moveLeft:(Float)frameTime;
- (void) moveRight:(Float)frameTime;

- (void) updateProjection;
- (void) updateView;

@end
