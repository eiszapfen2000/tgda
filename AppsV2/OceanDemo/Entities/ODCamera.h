#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "Input/NPEngineInputEnums.h"

typedef struct OdCameraMovementEvents
{
    NpInputEvent rotate;
    NpInputEvent strafe;
    NpInputEvent forward;
    NpInputEvent backward;
}
OdCameraMovementEvents;

@class NPInputAction;

@interface ODCamera : NPObject
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
    NPInputAction * rotateAction;
    NPInputAction * strafeAction;
    NPInputAction * forwardAction;
    NPInputAction * backwardAction;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName
     movementEvents:(OdCameraMovementEvents)movementEvents
                   ;

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

- (void) setNearPlane:(double)newNearPlane;
- (void) setFarPlane:(double)newFarPlane;
- (void) setPosition:(const Vector3)newPosition;
- (void) setOrientation:(const Quaternion)newOrientation;
- (void) setYaw:(const double)newYaw;
- (void) setPitch:(const double)newPitch;

- (void) lockInput;
- (void) unlockInput;

- (void) update:(const double)frameTime;
- (void) render;

@end
