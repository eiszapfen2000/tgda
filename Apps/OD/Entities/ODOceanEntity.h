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

    id projectedGridCPU;
    id projectedGridR2VB;

    id currentStaticTile;
    id currentAnimatedTile;
    NSMutableArray * staticTiles;
    NSMutableArray * animatedTiles;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (NpState) mode;
- (IVector2) projectedGridResolution;

- (void) setMode:(NpState)newMode;
- (void) setProjectedGridResolution:(IVector2)newProjectedGridResolution;

@end

