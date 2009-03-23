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
    NSMutableDictionary * rngs;

    IVector2 * size;
    IVector2 * baseResolution;
    IVector2 * currentResolution;
    IVector2 * lastResolution;

    FPGMImage * image;
    Float H;
    Float sigma;
    Float variance;

    Float minimumHeight;
    Float maximumHeight;

    Int32 iterations;
    Int32 currentIteration;
    Int32 iterationsDone;
    Int32 baseIterations;
    Int32 currentLod;

    NPEffect * effect;
    NPTexture * texture;
    NSMutableArray * lods;

    FVector3 * lightPosition;
    CGparameter lightPositionParameter;

    NPGaussianRandomNumberGenerator * gaussianRng;

    NPAction * subdivideAction;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (Int) width;
- (Int) length;
- (Float) H;
- (Float) sigma;
- (Float) minimumHeight;
- (Float) maximumHeight;
- (Int32) currentLod;

- (void) setCurrentLod:(Int32)newCurrentLod;
- (void) setWidth:(Int32)newWidth;
- (void) setLength:(Int32)newLength;
- (void) setMinimumHeight:(Float)newMinimumHeight;
- (void) setMaximumHeight:(Float)newMaximumHeight;
- (void) setRngOneUsingName:(NSString *)newRngOneName;
- (void) setRngTwoUsingName:(NSString *)newRngTwoName;
- (void) setRngOneSeed:(ULong)newSeed;
- (void) setRngTwoSeed:(ULong)newSeed;
- (void) setH:(Float)newH;
- (void) setSigma:(Float)newSigma;
- (void) setIterations:(Int32)newIterations;


- (BOOL) loadFromPath:(NSString *)path;

- (void) updateGeometry;
- (void) update:(Float)frameTime;
- (void) render;

@end
