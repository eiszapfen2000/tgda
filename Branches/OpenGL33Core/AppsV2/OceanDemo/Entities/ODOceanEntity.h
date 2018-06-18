#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"
#import "Ocean/ODPFrequencySpectrumGeneration.h"
#import "ODPEntity.h"
#import "fftw3.h"

@class NSCondition;
@class NSLock;
@class NSMutableArray;
@class NSPointerArray;
@class NSThread;
@class NPTimer;
@class NPTextureBuffer;
@class NPTexture2D;
@class NPTexture2DArray;
@class NPBufferObject;
@class NPVertexArray;
@class ODCamera;
@class ODProjector;
@class ODBasePlane;
@class ODHeightfieldQueue;

#define ODOCEANENTITY_NUMBER_OF_RESOLUTIONS 6

@interface ODOceanEntity : NPObject
{
    NSCondition * generateCondition;
    NSCondition * transformCondition;
    NSLock * spectrumQueueMutex;
    NSLock * heightfieldQueueMutex;
    NSLock * settingsMutex;

    Vector2 windDirection;
    double lastWindSpeed;
    double windSpeed;
    double generatorWindSpeed;
    double lastSize;
    double size;
    double generatorSize;
    double lastFetch;
    double fetch;
    double generatorFetch;
    double lastSpectrumScale;
    double spectrumScale;
    double generatorSpectrumScale;
    NSUInteger lastGeometryResolutionIndex;
    NSUInteger geometryResolutionIndex;
    NSUInteger generatorGeometryResolutionIndex;
    NSUInteger lastGradientResolutionIndex;
    NSUInteger gradientResolutionIndex;
    NSUInteger generatorGradientResolutionIndex;
    NSInteger lastNumberOfLods;
    NSInteger numberOfLods;
    NSInteger generatorNumberOfLods;
    NSUInteger lastSpectrumType;
    NSUInteger spectrumType;
    NSUInteger generatorSpectrumType;
    NSUInteger lastOptions;
    NSUInteger options;
    NSUInteger generatorOptions;

    BOOL generateData;
    BOOL transformData;

    fftwf_plan complexPlans[ODOCEANENTITY_NUMBER_OF_RESOLUTIONS];
    
    NSThread * generatorThread;
    NSThread * transformThread;
    NSPointerArray * spectrumQueue;
    NSPointerArray * varianceQueue;
    ODHeightfieldQueue * resultQueue;

    ODProjector * projector;
    ODBasePlane * basePlane;

    NPBufferObject * sizesStorage;
    NPTextureBuffer * sizes;
    NPTexture2DArray * baseSpectrum;

    NPTexture2DArray * heightfield;
    NPTexture2DArray * displacement;
    NPTexture2DArray * gradient;
    NPTexture2DArray * displacementDerivatives;

    NPTexture2D * waterColor;
    NPTexture2D * waterColorIntensity;
    Vector2 waterColorCoordinate;
    Vector2 waterColorIntensityCoordinate;

    double displacementScale;

    BOOL receivedHeight;
    BOOL receivedDisplacement;
    BOOL receivedGradient;
    BOOL receivedDisplacementDerivatives;

    FVector2 * heightRanges;
    FVector2 * gradientXRanges;
    FVector2 * gradientZRanges;
    FVector2 * displacementXRanges;
    FVector2 * displacementZRanges;
    FVector2 * displacementXdXRanges;
    FVector2 * displacementXdZRanges;
    FVector2 * displacementZdXRanges;
    FVector2 * displacementZdZRanges;

    IVector2 baseSpectrumResolution;
    Vector2  baseSpectrumSize;
    float baseSpectrumDeltaVariance;
    BOOL updateSlopeVariance;

    BOOL animated;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (void) start;
- (void) stop;

- (ODProjector *) projector;
- (ODBasePlane *) basePlane;
- (NPTexture2DArray *) baseSpectrum;
- (NPTextureBuffer *) sizes;
- (NPTexture2DArray *) heightfield;
- (NPTexture2DArray *) displacement;
- (NPTexture2DArray *) gradient;
- (NPTexture2DArray *) displacementDerivatives;
- (NPTexture2D *) waterColor;
- (NPTexture2D *) waterColorIntensity;

- (double) displacementScale;
- (Vector2) waterColorCoordinate;
- (Vector2) waterColorIntensityCoordinate;

- (IVector2) baseSpectrumResolution;
- (Vector2)  baseSpectrumSize;
- (float)    baseSpectrumDeltaVariance;

- (BOOL) updateSlopeVariance;

- (void) setCamera:(ODCamera *)newCamera;

- (void) update:(const double)frameTime;
- (void) renderBasePlane;

@end

