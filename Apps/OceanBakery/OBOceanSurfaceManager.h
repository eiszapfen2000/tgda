#import "Core/NPObject/NPObject.h"

@interface OBOceanSurfaceManager : NPObject
{
    NSMutableDictionary * frequencySpectrumGenerators;
    NSMutableDictionary * configurations;
    id currentConfiguration;
    NSUInteger processorCount;

}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (id) frequencySpectrumGenerators;
- (id) currentConfiguration;
- (void) setCurrentConfiguration:(id)newCurrentConfiguration;

- (id) loadFromPath:(NSString *)path;
- (id) loadFromAbsolutePath:(NSString *)path;

- (void) processConfigurations;

@end
