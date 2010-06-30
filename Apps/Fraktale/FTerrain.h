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
    NSMutableArray * lods;

    NSMutableDictionary * rngs;
    NPGaussianRandomNumberGenerator * gaussianRng;

    IVector2 * baseResolution;
    IVector2 * size;
    FVector2 * heightRange;
    FVector3 * lightDirection;
    FVector2 * texCoordTiling;

    Float H;
    Float sigma;
    Float variance;

    Int gaussKernelWidth;
    Float gaussKernelSigma;
    Float * gaussKernel;

    NPEffect * effect;
    CGparameter lightDirectionParameter;
    CGparameter cameraPositionParameter;
    CGparameter texCoordTilingParameter;
    CGparameter heightRangeParameter;

    BOOL useAO;
    BOOL useSpecular;

    NPTexture * sandDiffuseTexture;
    NPTexture * sandSpecularTexture;
    NPTexture * grassDiffuseTexture;
    NPTexture * grassSpecularTexture;
    NPTexture * stoneDiffuseTexture;
    NPTexture * stoneSpecularTexture;

    UInt32 lodToRender;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent;
- (void) dealloc;

- (Float) H;
- (Float) sigma;
- (void) setLODToRender:(UInt32)newLODToRender;

- (BOOL) loadFromDictionary:(NSDictionary *)dictionary;
- (void) reset;

- (void) setupGaussianKernelForAOWithSigma:(Float)sigma;

- (void) updateGeometryUsingSize:(IVector2)newSize
                     heightRange:(FVector2)newHeightRange
                           sigma:(Float)newSigma
                               H:(Float)newH
              numberOfIterations:(UInt32)numberOfIterations
                      rngOneName:(NSString *)rngOneName
                      rngOneSeed:(Long)rngOneSeed
                      rngTwoName:(NSString *)rngTwoName
                      rngTwoSeed:(Long)rngTwoSeed
                                ;

//- (void) updateGeometry;
- (void) update:(Float)frameTime;
- (void) render;

@end

