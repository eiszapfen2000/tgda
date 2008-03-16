#import "Core/NPObject/NPObject.h"
#import "Core/Math/FMatrix.h"

@interface NPTransformationState : NPObject
{
    FMatrix4 * modelMatrix;
    FMatrix4 * viewMatrix;
    FMatrix4 * projectionMatrix;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (FMatrix4 *)modelMatrix;
- (void) setModelMatrix:(FMatrix4 *)newModelMatrix;
- (FMatrix4 *)viewMatrix;
- (void) setViewMatrix:(FMatrix4 *)newViewMatrix;
- (FMatrix4 *)projectionMatrix;
- (void) setProjectionMatrix:(FMatrix4 *)newProjectionMatrix;

@end
