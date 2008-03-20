#import "Core/NPObject/NPObject.h"
#import "Core/Math/NpMath.h"

@interface NPCamera : NPObject
{
    FMatrix4 * view;
    FMatrix4 * projection;

    Quaternion * orientation;
    FVector3 * position;

    Float fieldOfView;
    Float aspectRatio;
    Float nearPlane;
    Float farPlane;
}

- (id) init;
- (id) initWithParent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (void) reset;
- (void) resetMatrices;
- (void) resetOrientation;

- (FMatrix4 *) view;
- (FMatrix4 *) projection;

- (void) rotateX:(Double)degrees;
- (void) rotateY:(Double)degrees;
- (void) rotateZ:(Double)degrees;

- (FVector3 *) position;
- (void) setPosition:(FVector3 *)newPosition;

- (void) update;
- (void) updateViewMatrix;
- (void) updateProjectionMatrix;

- (void) activate;

- (void) render;

@end
