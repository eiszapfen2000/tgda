#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "ODPEntity.h"

@class NPVertexBuffer;
@class NPEffect;

@interface ODOceanEntity : NPObject < ODPEntity >
{
    IVector2 * resolution;
    UInt32 numberOfSlices;
    Float ** heights;

    NPEffect * effect;
    NSMutableArray * textures;
    NPVertexBuffer * vertexBuffer;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

@end

