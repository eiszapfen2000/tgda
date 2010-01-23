#import <Foundation/NSDictionary.h>
#import "AL/al.h"
#import "AL/alc.h"
#import "Core/NPObject/NPObject.h"

@class NPSoundSample;

@interface NPSoundManager : NPObject
{
    NSMutableDictionary * samples;
    NSMutableDictionary * streams;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (id) loadSampleFromPath:(NSString *)path;
- (id) loadSampleFromAbsolutePath:(NSString *)path;

- (void) update;

@end
