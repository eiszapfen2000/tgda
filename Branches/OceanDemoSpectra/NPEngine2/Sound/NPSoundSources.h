#import <Foundation/NSArray.h>
#import "AL/al.h"
#import "AL/alc.h"
#import "Core/NPObject/NPObject.h"

@class NSError;
@class NPSoundSource;
@class NPSoundSample;
@class NPSoundStream;

@interface NPSoundSources : NPObject
{
    NSMutableArray * sources;
}

- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (BOOL) startup;
- (void) shutdown;

- (NSUInteger) numberOfSources;
- (NPSoundSource *) sourceAtIndex:(NSUInteger)index;
- (NPSoundSource *) firstFreeSource;

- (void) pauseAllSources;
- (void) stopAllSources;
- (void) resumeAllSources;

- (NPSoundSource *) reserveSource;
- (NPSoundSource *) playSample:(NPSoundSample *)sample;
- (NPSoundSource *) playStream:(NPSoundStream *)stream;

- (void) update;

@end
