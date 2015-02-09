#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "ODEntity.h"

@class NPStateSet;
@class NSMutableArray;

@interface ODTerrain : NPObject < ODPEntity >
{
    NPStateSet * stateset;
    NSMutableArray * models;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

@end

