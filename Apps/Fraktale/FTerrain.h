#import "Core/NPObject/NPObject.h"
#import "Core/Math/NpMath.h"
#import "Graphics/npgl.h"

@class FPGMImage;
@class NPVertexBuffer;
@class NPEffect;

@interface FTerrain : NPObject
{
    FPGMImage * image;
    Float H;
    Int32 iterations;

    NPVertexBuffer * geometry;
    NPEffect * effect;
    FVector3 * lightPosition;
    CGparameter lightPositionParameter;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (BOOL) loadFromPath:(NSString *)path;

- (void) update:(Float)frameTime;
- (void) render;

@end
