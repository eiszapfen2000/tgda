#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"

@interface TOCamera : NPObject
{
	FMatrix4 * view;
	FMatrix4 * projection;

    Quaternion * orientation;
    FVector3 * position;

	Float fov;
	Float nearPlane;
	Float farPlane;
	Float aspectRatio;
}

- (id) init;
- (id) initWithParent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (void) reset;

- (FVector3 *) position;
- (void) setPosition:(FVector3 *)newPosition;
- (void) setFov:(Float)newFov;
- (void) setNearPlane:(Float)newNearPlane;
- (void) setFarPlane:(Float)newFarPlane;
- (void) setAspectRatio:(Float)newAspectRatio;

- (void) updateProjection;
- (void) updateView;
- (void) update;

- (void) render;

@end
