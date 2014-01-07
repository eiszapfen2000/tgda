#import "Core/Math/FMatrix.h"
#import "Core/NPObject/NPObject.h"

@interface NPOrthographic : NPObject
{
    FMatrix4 modelBefore;
    FMatrix4 viewBefore;
    FMatrix4 projectionBefore;
}

+ (float) top;
+ (float) bottom;
+ (float) left;
+ (float) right;
+ (FVector2) topCenter;
+ (FVector2) bottomCenter;
+ (FVector2) leftCenter;
+ (FVector2) rightCenter;
+ (FVector2) alignTop:(const FVector2)vector;
+ (FVector2) alignBottom:(const FVector2)vector;
+ (FVector2) alignLeft:(const FVector2)vector;
+ (FVector2) alignRight:(const FVector2)vector;
+ (FVector2) alignTopLeft:(const FVector2)vector;
+ (FVector2) alignTopRight:(const FVector2)vector;
+ (FVector2) alignBottomLeft:(const FVector2)vector;
+ (FVector2) alignBottomRight:(const FVector2)vector;

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (void) activate;
- (void) deactivate;

@end

