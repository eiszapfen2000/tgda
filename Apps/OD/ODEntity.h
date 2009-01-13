#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"

@interface ODEntity : NPObject
{
    id config;
    id model;
    id stateset;
    FMatrix4 * modelMatrix;
    FVector3 * position;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (BOOL) loadFromPath:(NSString *)path;

- (FVector3 *) position;
- (void) setPosition:(FVector3 *)newPosition;

- (void) update;
- (void) render;

@end

