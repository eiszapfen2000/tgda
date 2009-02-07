#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"

@interface OBOceanSurfaceGenerationConfiguration : NPObject
{
    IVector2 * resolution;
    IVector2 * size;
    FVector2 * windDirection;
    NSString * generatorName;
    NSString * outputFileName;
    id gaussianRNG;
    Int numberOfThreads;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (BOOL) loadFromPath:(NSString *)path;

- (void) activate;
- (void) deactivate;
- (void) process;

@end
