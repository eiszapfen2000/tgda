#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "ODPEntity.h"

@class NPStateSet;

@interface ODOceanEntity : NPObject < ODPEntity >
{
    NPStateSet * stateset;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

@end

