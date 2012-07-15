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
	double fov;
	double nearPlane;
	double farPlane;
	double aspectRatio;
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

- (double) fov;
- (double) aspectRatio;
- (double) nearPlane;
- (double) farPlane;
- (Vector3) forward;
- (Vector3) position;
- (Quaternion) orientation;
- (double) yaw;
- (double) pitch;
- (Matrix4 *) view;
- (Matrix4 *) projection;
- (Matrix4 *) inverseViewProjection;
- (BOOL) inputLocked;

- (void) setPosition:(const Vector3)newPosition;
- (void) setOrientation:(const Quaternion)newOrientation;
- (void) setYaw:(const double)newYaw;
- (void) setPitch:(const double)newPitch;

- (void) lockInput;
- (void) unlockInput;

@end
