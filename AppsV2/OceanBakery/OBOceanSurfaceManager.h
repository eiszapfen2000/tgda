#import "Core/NPObject/NPObject.h"

@class NSMutableArray;
@class NSMutableDictionary;
@class NPFile;
@class OBOceanSurface;


@interface OBOceanSurfaceManager : NPObject
{
    NSMutableDictionary * frequencySpectrumGenerators;
    NSMutableDictionary * configurations;
    NSMutableArray * oceanSurfaces;
    NSUInteger processorCount;

}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (id) frequencySpectrumGenerators;

- (id) loadOceanSurfaceGenerationConfigurationFromPath:(NSString *)path;
- (id) loadOceanSurfaceGenerationConfigurationFromAbsolutePath:(NSString *)path;

- (void) saveOceanSurface:(OBOceanSurface *)oceanSurface atAbsolutePath:(NSString *)path;
- (void) saveOceanSurface:(OBOceanSurface *)oceanSurface toFile:(NPFile *)file;

- (void) processConfigurations;

@end
