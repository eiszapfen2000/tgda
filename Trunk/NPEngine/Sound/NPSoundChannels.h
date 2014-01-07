#import <Foundation/NSArray.h>
#import "AL/al.h"
#import "AL/alc.h"
#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"

@class NPSoundChannel;
@class NPSoundSample;

@interface NPSoundChannels : NPObject
{
    NSMutableArray * channels;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) setup;

- (UInt32) numberOfChannels;
- (NPSoundChannel *) channelAtIndex:(UInt32)index;
- (NPSoundChannel *) firstFreeChannel;

- (void) pauseAllChannels;
- (void) stopAllChannels;
- (void) resumeAllChannels;

- (NPSoundChannel *) reserveChannel;
- (NPSoundChannel *) play:(NPSoundSample *)sample;

- (void) update;

@end
