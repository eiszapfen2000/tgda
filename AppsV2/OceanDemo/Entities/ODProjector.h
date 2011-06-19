#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "ODPEntity.h"

@class NPEffect;
@class NPInputAction;
@class ODCamera;
@class ODFrustum;

@interface ODProjector : NPObject < ODPEntity >
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

    BOOL connectedToCamera;
    ODCamera* camera;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (void) reset;

- (FVector3) position;
- (FMatrix4 *) view;
- (FMatrix4 *) projection;
- (FMatrix4 *) inverseViewProjection;
- (ODCamera *) camera;
- (ODFrustum *) frustum;

- (void) setPosition:(const FVector3)newPosition;
- (void) setCamera:(ODCamera *)newCamera;
- (void) setRenderFrustum:(BOOL)newRenderFrustum;

- (void) cameraRotateUsingYaw:(const float)yawDegrees andPitch:(const float)pitchDegrees;
- (void) moveForward;
- (void) moveBackward;

- (void) activate;

- (void) updateProjection;
- (void) updateView;

@end
