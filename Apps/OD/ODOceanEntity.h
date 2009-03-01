#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "Graphics/npgl.h"
#import "ODPEntity.h"

@class NPVertexBuffer;
@class NPEffect;

@interface ODOceanEntity : NPObject < ODPEntity >
{
    IVector2 * resolution;
    UInt32 numberOfSlices;
    Float * times;
    Float ** heights;

    NPEffect * effect;
    NSMutableArray * textures;
    NPVertexBuffer * nearPlaneGrid;
    NPVertexBuffer * projectedGrid;
    NSDictionary * projectedGridPBOs;

    CGparameter projectorIMVP;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

@end

