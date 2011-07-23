#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"

@interface ODPerlinNoise : NPObject
{
    uint32_t size;
    uint32_t * permutationTable;
    double * noise;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName
               size:(const uint32_t)newSize
                   ;
- (void) dealloc;

- (uint32_t) size;
- (void) setSize:(const uint32_t)newSize;

- (void) generate;

@end

