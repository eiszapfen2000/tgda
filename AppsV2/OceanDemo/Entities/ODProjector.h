#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "ODPEntity.h"

@class NPInputAction;
@class ODCamera;
@class ODFrustum;

@interface ODProjector : NPObject
{
	FMatrix4 view;
    FMatrix4 projection;
    FMatrix4 viewProjection;
    FMatrix4 inverseViewProjection;
    FQuaternion orientation;
    FVector3 position;

    float yaw;
    float pitch;
    FVector3 forward;
    FVector3 right;
    FVector3 up;

    float fov;
    float nearPlane;
    float farPlane;
    float aspectRatio;

    BOOL renderFrustum;
    ODFrustum * frustum;

    NPInputAction * pitchMinusAction;
    NPInputAction * pitchPlusAction;
    NPInputAction * yawMinusAction;
    NPInputAction * yawPlusAction;

    BOOL connectedToCameraLastFrame;
    BOOL connectedToCamera;
    ODCamera * camera;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (FVector3) position;
- (FQuaternion) orientation;
- (float) yaw;
- (float) pitch;
- (FMatrix4 *) view;
- (FMatrix4 *) projection;
- (FMatrix4 *) inverseViewProjection;
- (ODCamera *) camera;
- (ODFrustum *) frustum;

- (BOOL) connecting;
- (BOOL) disconnecting;

- (void) setPosition:(const FVector3)newPosition;
- (void) setCamera:(ODCamera *)newCamera;
- (void) setRenderFrustum:(BOOL)newRenderFrustum;

- (void) cameraRotateUsingYaw:(const float)yawDegrees andPitch:(const float)pitchDegrees;
- (void) moveForward;
- (void) moveBackward;

- (void) activate;

- (void) updateProjection;
- (void) updateView;

- (void) update:(const double)frameTime;
- (void) render;

@end
