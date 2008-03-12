#import "Core/NPObject/NPObject.h"
#import "Core/Math/NpMath.h"

@interface NPCamera : NPObject
{
    FMatrix4 * view;
    FMatrix4 * projection;

    Quaternion * orientation;
    Vector3 * position;

    Float fieldOfView;
    Float aspectRatio;
    Float nearPlane;
    Float farPlane;
}

- (id) init;
- (id) initWithParent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;

- (void) reset;
- (void) resetMatrices;
- (void) resetOrientation;

- (FMatrix4 *) view;
- (FMatrix4 *) projection;

- (void) rotateX:(Double)degrees;
- (void) rotateY:(Double)degrees;
- (void) rotateZ:(Double)degrees;

- (Vector3 *) position;
- (void) setPosition:(Vector3 *)newPosition;

@end
