#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"

@class NPFile;
@class OBOceanSurfaceSlice;

@interface OBOceanSurface : NPObject
{
    IVector2 * resolution;
    NSMutableArray * slices;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent resolution:(IVector2 *)newResolution;
- (void) dealloc;

- (void) addSlice:(OBOceanSurfaceSlice *)slice;

- (void) saveToFile:(NPFile *)file;

@end
