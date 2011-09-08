#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "ODPEntity.h"

@class NSThread;
@class NPTimer;
@class NPStateSet;

@interface ODOceanEntity : NPObject < ODPEntity >
{
    NSThread * thread;
    NPTimer * timer;
    NPStateSet * stateset;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

@end

