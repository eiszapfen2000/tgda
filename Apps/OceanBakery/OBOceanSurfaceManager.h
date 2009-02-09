#import "Core/NPObject/NPObject.h"

@class OBOceanSurface;
@class NPFile;

@interface OBOceanSurfaceManager : NPObject
{
    NSMutableDictionary * frequencySpectrumGenerators;
    NSMutableDictionary * configurations;
    NSMutableArray * oceanSurfaces;
    NSUInteger processorCount;

}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (id) frequencySpectrumGenerators;

- (id) loadOceanSurfaceGenerationConfigurationFromPath:(NSString *)path;
- (id) loadOceanSurfaceGenerationConfigurationFromAbsolutePath:(NSString *)path;

- (void) saveOceanSurface:(OBOceanSurface *)oceanSurface atAbsolutePath:(NSString *)path;
- (void) saveOceanSurface:(OBOceanSurface *)oceanSurface toFile:(NPFile *)file;

- (void) processConfigurations;

@end
