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
    CGparameter projectorIMVP;

    id wtexture;

    id renderTargetConfiguration;
    id r2vbConfiguration;

    NSMutableArray * textures;
    id texture3D;

    NPVertexBuffer * nearPlaneGrid;
    NPVertexBuffer * projectedGrid;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (id) renderTexture;

@end

