#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"

@class OBOceanSurface;

@interface OBOceanSurfaceGenerationConfiguration : NPObject
{
    IVector2 * resolution;
    IVector2 * size;
    FVector2 * windDirection;
    NSString * generatorName;
    NSString * outputFileName;
    id gaussianRNG;
    Int numberOfThreads;
    Int numberOfSlices;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (NSString *) outputFileName;

- (BOOL) loadFromPath:(NSString *)path;

- (OBOceanSurface *) process;

@end
