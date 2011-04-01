#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"

@class NSMutableArray;
@class NPFile;
@class OBOceanSurfaceSlice;

@interface OBOceanSurface : NPObject
{
    IVector2 resolution;
    FVector2 size;
    FVector2 windDirection;

    NSMutableArray * slices;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (void) setResolution:(const IVector2)newResolution;
- (void) setSize:(const FVector2)newSize;
- (void) setWindDirection:(const FVector2)newWindDirection;

- (void) addSlice:(OBOceanSurfaceSlice *)slice;

- (void) saveToFile:(NPFile *)file;

@end
