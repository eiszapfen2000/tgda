#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "Core/Protocols/NPPStream.h"

@class NSError;
@class NSMutableArray;
@class OBOceanSurfaceSlice;

@interface OBOceanSurface : NPObject
{
    IVector2 resolution;
    Vector2 size;
    Vector2 windDirection;

    NSMutableArray * slices;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (void) setResolution:(const IVector2)newResolution;
- (void) setSize:(const Vector2)newSize;
- (void) setWindDirection:(const Vector2)newWindDirection;

- (void) addSlice:(OBOceanSurfaceSlice *)slice;

- (BOOL) writeToStream:(id <NPPStream>)stream
                 error:(NSError **)error
                      ;

@end
