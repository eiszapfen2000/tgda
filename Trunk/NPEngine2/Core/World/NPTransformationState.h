#import "Core/NPObject/NPObject.h"
#import "Core/Math/FMatrix.h"
#import "Core/Math/Matrix.h"

@interface NPTransformationState : NPObject
{
    FMatrix4 * modelMatrix;
    FMatrix4 * inverseModelMatrix;
    FMatrix4 * viewMatrix;
    FMatrix4 * inverseViewMatrix;
    FMatrix4 * projectionMatrix;
    FMatrix4 * inverseProjectionMatrix;
    FMatrix4 * modelViewMatrix;
    FMatrix4 * inverseModelViewMatrix;
    FMatrix4 * viewProjectionMatrix;
    FMatrix4 * inverseViewProjectionMatrix;
    FMatrix4 * modelViewProjectionMatrix;
    FMatrix4 * inverseModelViewProjectionMatrix;

    BOOL recomputeInverseModelMatrix;
    BOOL recomputeInverseViewMatrix;
    BOOL recomputeInverseProjectionMatrix;
    BOOL recomputeModelViewMatrix;
    BOOL recomputeInverseModelViewMatrix;
    BOOL recomputeViewProjectionMatrix;
    BOOL recomputeInverseViewProjectionMatrix;
    BOOL recomputeModelViewProjectionMatrix;
    BOOL recomputeInverseModelViewProjectionMatrix;
}

- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (void) reset;
- (void) resetModelMatrix;
- (void) resetViewMatrix;
- (void) resetProjectionMatrix;

- (FMatrix4 *) modelMatrix;
- (FMatrix4 *) inverseModelMatrix;
- (FMatrix4 *) viewMatrix;
- (FMatrix4 *) inverseViewMatrix;
- (FMatrix4 *) projectionMatrix;
- (FMatrix4 *) inverseProjectionMatrix;
- (FMatrix4 *) modelViewMatrix;
- (FMatrix4 *) inverseModelViewMatrix;
- (FMatrix4 *) viewProjectionMatrix;
- (FMatrix4 *) inverseViewProjectionMatrix;
- (FMatrix4 *) modelViewProjectionMatrix;
- (FMatrix4 *) inverseModelViewProjectionMatrix;

- (void) setFModelMatrix:(const FMatrix4 * const)newModelMatrix;
- (void) setFViewMatrix:(const FMatrix4 * const)newViewMatrix;
- (void) setFProjectionMatrix:(const FMatrix4 * const)newProjectionMatrix;
- (void) setModelMatrix:(const Matrix4 * const)newModelMatrix;
- (void) setViewMatrix:(const Matrix4 * const)newViewMatrix;
- (void) setProjectionMatrix:(const Matrix4 * const)newProjectionMatrix;

- (void) computeInverseModelMatrix;
- (void) computeInverseViewMatrix;
- (void) computeInverseProjectionMatrix;
- (void) computeModelViewMatrix;
- (void) computeInverseModelViewMatrix;
- (void) computeViewProjectionMatrix;
- (void) computeInverseViewProjectionMatrix;
- (void) computeModelViewProjectionMatrix;
- (void) computeInverseModelViewProjectionMatrix;

@end
