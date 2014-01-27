#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"

@interface ODWorldCoordinateAxes : NPObject
{
    float axisLength;
    float colorMultiplier;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (float) axisLength;
- (void) setAxisLength:(float)newAxisLength;

- (void) update:(double)frameTime;
- (void) render;

@end

