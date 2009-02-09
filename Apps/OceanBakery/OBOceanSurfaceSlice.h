#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "fftw3.h"

@class NPFile;

@interface OBOceanSurfaceSlice : NPObject
{
    UInt elementCount;
    Float * heights;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) setHeights:(Float *)newHeights elementCount:(UInt)count;

- (void) saveToFile:(NPFile *)file;

@end
