#import "Core/NPObject/NPObject.h"

@class NPSUXModel;
@class ODCamera;
@class ODSurface;
@class ODProjector;
@class NPStateSet;

typedef struct ODSceneMovement
{
    unsigned int moveForward  : 1;
    unsigned int moveBackward : 1;
    unsigned int strafeLeft   : 1;
    unsigned int strafeRight  : 1;
}
ODSceneMovement;

@interface ODScene : NPObject
{
    ODCamera    * camera;
    ODProjector * projector;
    ODSurface   * surface;

    NPSUXModel  * skybox;
    NPStateSet * skyboxStateSet;

    ODSceneMovement movement;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (void) setup;

- (ODSurface *) surface;
- (ODCamera *) camera;
- (ODProjector *) projector;

- (void) update;
- (void) render;

- (void) activateForwardMovement;
- (void) deactivateForwardMovement;
- (void) activateBackwardMovement;
- (void) deactivateBackwardMovement;
- (void) activateStrafeLeft;
- (void) deactivateStrafeLeft;
- (void) activateStrafeRight;
- (void) deactivateStrafeRight;

- (void) cameraRotateUsingYaw:(Float)yaw andPitch:(Float)pitch;

@end
