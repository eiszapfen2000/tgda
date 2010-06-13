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

    Float H;
    Float sigma;
    Float variance;

    Float minimumHeight;
    Float maximumHeight;

    Int32 currentIteration;
    Int32 iterationsToDo;
    Int32 currentLod;

    Int gaussKernelWidth;
    Float gaussKernelSigma;
    Float * gaussKernel;

    NPTexture * grassTexture;
    NPTexture * stoneAndGrassTexture;
    NPTexture * stoneTexture;
    NSMutableArray * lods;

    FVector3 * lightDirection;
    NPEffect * effect;
    CGparameter lightDirectionParameter;

    NPGaussianRandomNumberGenerator * gaussianRng;
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
- (void) setRngOneUsingName:(NSString *)newRngOneName;
- (void) setRngTwoUsingName:(NSString *)newRngTwoName;
- (void) setRngOneSeed:(ULong)newSeed;
- (void) setRngTwoSeed:(ULong)newSeed;

- (void) setupGaussianKernelForAO;
- (void) setupGaussianKernelForAOWithSigma:(Float)kernelSigma;

- (BOOL) loadFromDictionary:(NSDictionary *)dictionary;
- (BOOL) loadFromPath:(NSString *)path;

- (void) reset;

- (void) updateGeometryUsingSize:(IVector2)newSize
                     heightRange:(FVector2)newHeightRange
                           sigma:(Float)newSigma
                               H:(Float)newH
              numberOfIterations:(UInt32)numberOfIterations
                                ;

//- (void) updateGeometry;
- (void) update:(Float)frameTime;
- (void) render;

@end

