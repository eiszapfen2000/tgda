#import "Core/NPObject/NPObject.h"

@interface ODPerlinNoise : NPObject
{
    Int size;
    id rng;
    Byte * permutationTable;
    Float * gradientX;
    Float * gradientY;
    Float * gradientZ;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent size:(Int)newSize;
- (void) dealloc;

- (Float) noise1D:(Float)x;

@end

