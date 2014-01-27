#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"

@interface ODWorldCoordinateAxes : NPObject
{
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (void) update:(double)frameTime;
- (void) render;

@end

