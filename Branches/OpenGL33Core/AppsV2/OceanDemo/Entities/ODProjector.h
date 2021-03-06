#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "Input/NPEngineInputEnums.h"

typedef struct OdProjectorRotationEvents
{
    NpInputEvent pitchMinus;
    NpInputEvent pitchPlus;
    NpInputEvent yawMinus;
    NpInputEvent yawPlus;
}
OdProjectorRotationEvents;

@class NPInputAction;
@class ODCamera;
@class ODFrustum;

@interface ODProjector : NPObject
{
	Matrix4 view;
    Matrix4 projection;
    Matrix4 range;
    Matrix4 viewProjection;
    Matrix4 inverseViewProjection;
    Quaternion orientation;
    Vector3 position;

    double yaw;
    double pitch;
    Vector3 forward;
    Vector3 right;
    Vector3 up;

    double lowerBound;
    double base;
    double upperBound;

    double fov;
    double nearPlane;
    double farPlane;
    double aspectRatio;

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
- (id) initWithName:(NSString *)newName
     rotationEvents:(OdProjectorRotationEvents)rotationEvents
                   ;
- (void) dealloc;

- (double) lowerBound;
- (double) base;
- (double) upperBound;

- (double) fov;
- (double) aspectRatio;
- (double) nearPlane;
- (double) farPlane;
- (Vector3) position;
- (Quaternion) orientation;
- (double) yaw;
- (double) pitch;
- (Matrix4 *) view;
- (Matrix4 *) projection;
- (Matrix4 *) inverseViewProjection;
- (ODCamera *) camera;

- (BOOL) connecting;
- (BOOL) disconnecting;

- (void) setLowerBound:(double)newLowerBound;
- (void) setBase:(double)newBase;
- (void) setUpperBound:(double)newUpperBound;

- (void) setPosition:(const Vector3)newPosition;
- (void) setCamera:(ODCamera *)newCamera;

- (void) update:(const double)frameTime;
- (void) render;

@end
