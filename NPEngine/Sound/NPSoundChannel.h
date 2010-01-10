#import <AL/al.h>
#import <AL/alc.h>
#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"

@interface NPSoundChannel : NPObject
{
    UInt32 channelIndex;
    UInt32 alID;
    FVector3 * position;
    FVector3 * positionLastFrame;
    Float pitch;
    Float volume;
    Float pitchVariation;
    Float volumeVariation;
    BOOL is3DSource;
    BOOL loop;
    BOOL locked;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject> )newParent
       channelIndex:(UInt32)newChannelIndex
               alID:(UInt32)newALID
                   ;
- (void) dealloc;

- (void) lock;
- (void) unlock;
- (BOOL) locked;

- (void) pause;
- (void) stop;
- (void) resume;
- (void) play;

- (UInt32) alID;
- (void) setPosition:(const FVector3 const *)newPosition;
- (void) setVolume:(Float)newVolume;
- (void) setPitch:(Float)newPitch;
- (void) setLooping:(BOOL)newLooping;

- (void) update;

@end
