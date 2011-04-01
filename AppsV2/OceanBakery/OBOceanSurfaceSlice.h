#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "fftw3.h"

@class NPFile;

@interface OBOceanSurfaceSlice : NPObject
{
    uint32_t elementCount;
    float time;
    float * heights;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (void) setTime:(float)newTime;
- (void) setHeights:(float *)newHeights
       elementCount:(uint32_t)count
                   ;

- (void) saveToFile:(NPFile *)file;

@end
