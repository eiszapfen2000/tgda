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

- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (void) shutdown;

- (NPSoundSample *) loadSampleFromFile:(NSString *)fileName;
- (NPSoundStream *) loadStreamFromFile:(NSString *)fileName;

- (void) update;

@end
