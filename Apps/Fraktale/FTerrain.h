#import "Core/NPObject/NPObject.h"
#import "Core/Math/NpMath.h"
#import "Graphics/npgl.h"

@class FPGMImage;
@class NPVertexBuffer;
@class NPSUXModel;
@class NPEffect;
@class NPTexture;
@class NPAction;
@class NPGaussianRandomNumberGenerator;

@interface FTerrain : NPObject
{
    IVector2 * size;
    IVector2 * baseResolution;
    IVector2 * currentResolution;
    IVector2 * lastResolution;

    FPGMImage * image;
    Float H;
    Float variance;

    Int32 iterations;
    Int32 currentIteration;
    Int32 iterationsDone;
    Int32 baseIterations;

    NPEffect * effect;
    NPTexture * texture;
    NSMutableArray * lods;

    FVector3 * lightPosition;
    CGparameter lightPositionParameter;

    NPGaussianRandomNumberGenerator * rng;

    NPAction * subdivideAction;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (BOOL) loadFromPath:(NSString *)path;

- (void) updateGeometry;
- (void) update:(Float)frameTime;
- (void) render;

@end
