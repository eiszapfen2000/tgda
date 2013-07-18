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
@class NPTexture2D;
@class NPBufferObject;
@class NPVertexArray;
@class ODCamera;
@class ODProjector;
@class ODBasePlane;
@class ODHeightfieldQueue;
@class ODOceanBaseMeshes;


#define ODOCEANENTITY_NUMBER_OF_RESOLUTIONS     8

@interface ODOceanEntity : NPObject
{
    NSCondition * generateCondition;
    NSCondition * transformCondition;
    NSLock * spectrumQueueMutex;
    NSLock * heightfieldQueueMutex;
    NSLock * settingsMutex;

    Vector2 lastWindDirection;
    Vector2 windDirection;
    Vector2 generatorWindDirection;
    double lastWindSpeed;
    double windSpeed;
    double generatorWindSpeed;
    Vector2 lastSize;
    Vector2 size;
    Vector2 generatorSize;
    NSUInteger lastResolutionIndex;
    NSUInteger resolutionIndex;
    NSUInteger generatorResolutionIndex;

    ODSpectrumSettings spectrumSettings;
    BOOL generateData;
    BOOL transformData;

    fftwf_plan complexPlans[ODOCEANENTITY_NUMBER_OF_RESOLUTIONS];
    fftwf_plan halfComplexPlans[ODOCEANENTITY_NUMBER_OF_RESOLUTIONS];
    
    NSThread * generatorThread;
    NSThread * transformThread;
    NSPointerArray * spectrumQueue;
    ODHeightfieldQueue * resultQueue;

    ODProjector * projector;
    ODBasePlane * basePlane;

    NPTexture2D * heightfield;
    NPTexture2D * supplementalData;

    ODOceanBaseMeshes * baseMeshes;
    NSUInteger baseMeshIndex;
    FVector2 baseMeshScale;

    double timeStamp;
    FVector2 heightRange;
    FVector2 gradientXRange;
    FVector2 gradientZRange;
    FVector2 displacementXRange;
    FVector2 displacementZRange;
    BOOL animated;

    FMatrix4 modelMatrix;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (void) start;
- (void) stop;

- (const FMatrix4 * const) modelMatrix;
- (ODProjector *) projector;
- (ODBasePlane *) basePlane;
- (NPTexture2D *) heightfield;
- (NPTexture2D *) supplementalData;

- (FVector2) heightRange;
- (FVector2) baseMeshScale;
- (void) setCamera:(ODCamera *)newCamera;

- (void) update:(const double)frameTime;
- (void) renderBasePlane;
- (void) renderBaseMesh;

@end

