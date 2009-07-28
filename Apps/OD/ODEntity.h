#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "ODPEntity.h"

@interface ODEntity : NPObject < ODPEntity >
{
    id model;
    id stateset;
    FMatrix4 * modelMatrix;
    FVector3 * position;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (id) model;
- (FVector3 *) position;
- (void) setPosition:(FVector3 *)newPosition;

@end

