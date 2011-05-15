#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "ODPEntity.h"

@class NPEffect;
@class NPInputAction;
@class ODCamera;
@class ODFrustum;

#define NEARPLANE_LOWERLEFT    0
#define NEARPLANE_LOWERRIGHT   1
#define NEARPLANE_UPPERRIGHT   2
#define NEARPLANE_UPPERLEFT    3
#define FARPLANE_LOWERLEFT     4
#define FARPLANE_LOWERRIGHT    5
#define FARPLANE_UPPERRIGHT    6
#define FARPLANE_UPPERLEFT     7

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

- (FVector3 *) position;
- (FMatrix4 *) view;
- (FMatrix4 *) projection;
- (FMatrix4 *) inverseViewProjection;
- (ODCamera *) camera;
- (ODFrustum *) frustum;

- (void) setPosition:(FVector3 *)newPosition;
- (void) setCamera:(ODCamera *)newCamera;
- (void) setRenderFrustum:(BOOL)newRenderFrustum;

- (void) cameraRotateUsingYaw:(float)yawDegrees andPitch:(float)pitchDegrees;
- (void) moveForward;
- (void) moveBackward;

- (void) activate;

- (void) updateProjection;
- (void) updateView;

@end
