#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "ODPEntity.h"

@class NPSUX2Model;
@class NPStateSet;

@interface ODEntity : NPObject < ODPEntity >
{
    NPSUX2Model * model;
    NPStateSet * stateset;
    FMatrix4 modelMatrix;
    FVector3 position;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (NPSUX2Model *) model;
- (FVector3) position;
- (void) setPosition:(const FVector3)newPosition;

@end

