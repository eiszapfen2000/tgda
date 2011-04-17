#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"

@class NSError;
@class OBOceanSurface;
@class OBGaussianRNG;
@class OBOceanSurfaceManager;

@interface OBOceanSurfaceGenerationConfiguration : NPObject
{
    IVector2 resolution;
    Vector2 size;
    Vector2 windDirection;
    NSString * generatorName;
    NSString * outputFileName;
    OBGaussianRNG * gaussianRNG;
    NSUInteger numberOfThreads;
    NSUInteger numberOfSlices;
    double * timeStamps;
    OBOceanSurfaceManager * oceanSurfaceManager;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName
            manager:(OBOceanSurfaceManager *)manager
                   ;
- (void) dealloc;

- (NSString *) outputFileName;

- (BOOL) loadFromFile:(NSString *)fileName
                error:(NSError **)error
                     ;

- (OBOceanSurface *) process;

@end
