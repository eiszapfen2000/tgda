#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "ODPEntity.h"

@class NPFile;
@class NPTexture3D;

@interface ODOceanAnimatedTile : NPObject
{
    IVector2 * resolution;
    FVector2 * size; // kilometers
    FVector2 * windDirection;

    UInt32 numberOfSlices;
    Float * times;
    Float ** heights;

    NSMutableArray * textures2D;
    NPTexture3D * texture3D;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (BOOL) loadFromFile:(NPFile *)file;

@end

