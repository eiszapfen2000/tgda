#import "Core/NPObject/NPObject.h"
#import "Core/Math/FMatrix.h"

@interface NPOrthographicRendering : NPObject
{
    FMatrix4 * tmpModelMatrix;
    FMatrix4 * tmpViewMatrix;
    FMatrix4 * tmpProjectionMatrix;

    FMatrix4 * modelMatrix;
    FMatrix4 * viewMatrix;
    FMatrix4 * projectionMatrix;

    id transformationStateToModifiy;    
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) activate;
- (void) deactivate;

@end
