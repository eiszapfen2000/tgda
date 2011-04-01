#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"

@class OBOceanSurface;
@class OBGaussianRNG;
@class OBOceanSurfaceManager;

@interface OBOceanSurfaceGenerationConfiguration : NPObject
{
    IVector2 resolution;
    FVector2 size;
    FVector2 windDirection;
    NSString * generatorName;
    NSString * outputFileName;
    OBGaussianRNG * gaussianRNG;
    int32_t numberOfThreads;
    int32_t numberOfSlices;
    float * timeStamps;
    OBOceanSurfaceManager * oceanSurfaceManager;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName
            manager:(OBOceanSurfaceManager *)manager
                   ;
- (void) dealloc;

- (NSString *) outputFileName;

- (BOOL) loadFromPath:(NSString *)path;

- (OBOceanSurface *) process;

@end
