#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"

@class NPFile;
@class OBOceanSurfaceSlice;

@interface OBOceanSurface : NPObject
{
    IVector2 * resolution;
    FVector2 * size;
    FVector2 * windDirection;

    NSMutableArray * slices;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) setResolution:(IVector2 *)newResolution;
- (void) setSize:(FVector2 *)newSize;
- (void) setWindDirection:(FVector2 *)newWindDirection;

- (void) addSlice:(OBOceanSurfaceSlice *)slice;

- (void) saveToFile:(NPFile *)file;

@end
