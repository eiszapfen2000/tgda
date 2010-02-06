#import <Foundation/NSDictionary.h>
#import "AL/al.h"
#import "AL/alc.h"
#import "Core/NPObject/NPObject.h"

@class NPSoundSample;
@class NPSoundStream;

@interface NPSoundManager : NPObject
{
    NSMutableDictionary * samples;
    NSMutableDictionary * streams;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (NPSoundSample *) loadSampleFromPath:(NSString *)path;
- (NPSoundSample *) loadSampleFromAbsolutePath:(NSString *)path;

- (NPSoundStream *) loadStreamFromPath:(NSString *)path;
- (NPSoundStream *) loadStreamFromAbsolutePath:(NSString *)path;

- (void) update;

@end
