#import "AL/al.h"
#import "AL/alc.h"
#import "Core/Math/NpMath.h"
#import "Core/NPObject/NPObject.h"

@class NPSoundSample;
@class NPSoundStream;

@interface NPSoundSource : NPObject
{
    NSUInteger sourceIndex;
    ALuint alID;
    FVector3 position;
    FVector3 positionLastFrame;
    Float pitch;
    Float volume;
    Float pitchVariation;
    Float volumeVariation;
    BOOL is3DSource;
    BOOL looping;
    BOOL locked;
    NPSoundSample * currentSample;
    NPSoundStream * currentStream;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject> )newParent
        sourceIndex:(NSUInteger)newSourceIndex
               alID:(ALuint)newALID
                   ;
- (void) dealloc;

- (void) clear;
- (void) reset;

- (void) lock;
- (void) unlock;
- (BOOL) locked;

- (void) pause;
- (void) stop;
- (void) resume;
- (void) playSample:(NPSoundSample *)sample;
- (void) playStream:(NPSoundStream *)stream;

- (ALuint) alID;
- (BOOL) paused;
- (BOOL) playing;
- (BOOL) looping;
- (void) setPosition:(const FVector3)newPosition;
- (void) setVolume:(Float)newVolume;
- (void) setPitch:(Float)newPitch;
- (void) setLooping:(BOOL)newLooping;

- (void) update;

@end
