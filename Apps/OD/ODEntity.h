#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"

@interface ODEntity : NPObject
{
    id config;
    id model;
    id stateset;
    FVector3 * position;

}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (void) dealloc;

- (BOOL) loadFromPath:(NSString *)path;

@end

