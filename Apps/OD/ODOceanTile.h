#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "ODPEntity.h"

@class NPFile;
@class NPTexture;

@interface ODOceanTile : NPObject
{
    IVector2 * resolution;
    FVector2 * size; // kilometers
    FVector2 * windDirection;

    Float * heights;

    NPTexture * texture;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (NPTexture *) texture;

- (BOOL) loadFromFile:(NPFile *)file;

@end

