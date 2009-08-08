#import "Core/NPObject/NPObject.h"
#import "Core/Math/FMatrix.h"

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

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) reset;

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

- (void) setModelMatrix:(FMatrix4 *)newModelMatrix;
- (void) setViewMatrix:(FMatrix4 *)newViewMatrix;
- (void) setProjectionMatrix:(FMatrix4 *)newProjectionMatrix;

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
