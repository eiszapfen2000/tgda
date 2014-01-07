#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"

@class NPFile;
@class NPTexture2D;
@class NPTexture3D;

@interface ODOceanAnimatedTile : NPObject
{
    IVector2 * resolution;
    FVector2 * size; // kilometers
    FVector2 * windDirection;

    UInt32 numberOfSlices;
    Float * times;
    Float ** heights;

    Float minimumTime;
    Float maximumTime;
    Float animationDuration;

    NSMutableArray * textures2D;
    NPTexture3D * texture3D;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (Float) minimumTime;
- (Float) maximumTime;
- (Float) animationDuration;

- (NPTexture3D *) texture3D;
- (NPTexture2D *) sliceAtIndex:(UInt32)index;

- (BOOL) loadFromFile:(NPFile *)file;

@end

