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

+ (Float) top;
+ (Float) bottom;
+ (Float) left;
+ (Float) right;
+ (FVector2) alignTop:(FVector2)vector;
+ (FVector2) alignBottom:(FVector2)vector;
+ (FVector2) alignLeft:(FVector2)vector;
+ (FVector2) alignRight:(FVector2)vector;

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) activate;
- (void) deactivate;

@end
