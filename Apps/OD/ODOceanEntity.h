#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "Graphics/npgl.h"
#import "ODPEntity.h"

@class NPVertexBuffer;
@class NPEffect;

#define ODOCEAN_STATIC  0
#define ODOCEAN_DYNAMIC 1

@interface ODOceanEntity : NPObject < ODPEntity >
{
    IVector2 * projectedGridResolution;
    IVector2 * projectedGridResolutionLastFrame;

    NpState mode;

    id currentStaticTile;
    id currentAnimatedTile;
    NSMutableArray * staticTiles;
    NSMutableArray * animatedTiles;

    NPEffect * effect;
    CGparameter projectorIMVP;
    CGparameter deltaTime;

    Float periodTime;

    id renderTargetConfiguration;
    id r2vbConfiguration;

    NPVertexBuffer * nearPlaneGrid;
    NPVertexBuffer * projectedGrid;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (NpState) mode;
- (IVector2) projectedGridResolution;
- (id) renderTexture;

- (void) setMode:(NpState)newMode;
- (void) setProjectedGridResolution:(IVector2)newProjectedGridResolution;

@end

