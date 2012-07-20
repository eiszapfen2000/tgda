#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "ODPEntity.h"

@class NPInputAction;
@class ODCamera;
@class ODFrustum;

@interface ODProjector : NPObject
{
	Matrix4 view;
    Matrix4 projection;
    Matrix4 viewProjection;
    Matrix4 inverseViewProjection;
    Quaternion orientation;
    Vector3 position;

    double yaw;
    double pitch;
    Vector3 forward;
    Vector3 right;
    Vector3 up;

    double fov;
    double nearPlane;
    double farPlane;
    double aspectRatio;

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

- (Vector3) position;
- (Quaternion) orientation;
- (double) yaw;
- (double) pitch;
- (Matrix4 *) view;
- (Matrix4 *) projection;
- (Matrix4 *) inverseViewProjection;
- (ODCamera *) camera;
- (ODFrustum *) frustum;

- (BOOL) connecting;
- (BOOL) disconnecting;

- (void) setPosition:(const Vector3)newPosition;
- (void) setCamera:(ODCamera *)newCamera;
- (void) setRenderFrustum:(BOOL)newRenderFrustum;

- (void) update:(const double)frameTime;
- (void) render;

@end
