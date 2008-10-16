#import "Core/NPObject/NPObject.h"
#import "Core/Math/FMatrix.h"

@interface NPTransformationState : NPObject
{
    FMatrix4 * modelMatrix;
    FMatrix4 * viewMatrix;
    FMatrix4 * projectionMatrix;
    FMatrix4 * modelViewMatrix;
    FMatrix4 * viewProjectionMatrix;
    FMatrix4 * modelViewProjectionMatrix;
    FMatrix4 * inverseViewProjectionMatrix;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (FMatrix4 *)modelMatrix;
- (void) setModelMatrix:(FMatrix4 *)newModelMatrix;
- (FMatrix4 *)viewMatrix;
- (void) setViewMatrix:(FMatrix4 *)newViewMatrix;
- (FMatrix4 *)projectionMatrix;
- (void) setProjectionMatrix:(FMatrix4 *)newProjectionMatrix;

- (FMatrix4 *) modelViewMatrix;
- (FMatrix4 *) viewProjectionMatrix;
- (FMatrix4 *) modelViewProjectionMatrix;
- (FMatrix4 *) inverseViewProjectionMatrix;


- (void) computeCombinedMatrices;

@end
