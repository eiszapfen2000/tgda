#import <Foundation/NSArray.h>
#import "AL/al.h"
#import "AL/alc.h"
#import "Core/NPObject/NPObject.h"

@class NSError;
@class NPSoundSource;
@class NPSoundSample;

@interface NPSoundSources : NPObject
{
    NSMutableArray * sources;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (BOOL) startup:(NSError **)error;
- (void) shutdown;

- (NSUInteger) numberOfSources;
- (NPSoundSource *) sourceAtIndex:(NSUInteger)index;
- (NPSoundSource *) firstFreeSource;

- (void) pauseAllSources;
- (void) stopAllSources;
- (void) resumeAllSources;

- (NPSoundSource *) reserveSource;
- (NPSoundSource *) play:(NPSoundSample *)sample;

- (void) update;

@end
