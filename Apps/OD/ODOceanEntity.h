#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "Graphics/npgl.h"
#import "ODPEntity.h"

@class NPVertexBuffer;
@class NPEffect;

@interface ODOceanEntity : NPObject < ODPEntity >
{
    IVector2 * resolution;

    NSMutableArray * staticTiles;
    NSMutableArray * animatedTiles;

    NPEffect * effect;
    CGparameter projectorIMVP;

    id renderTargetConfiguration;
    id r2vbConfiguration;

    NPVertexBuffer * nearPlaneGrid;
    NPVertexBuffer * projectedGrid;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (id) renderTexture;

@end

