#import <Foundation/NSException.h>
#import "Core/NPEngineCore.h"
#import "NPSoundSample.h"
#import "NPSoundStream.h"
#import "NPSoundSource.h"

@interface NPSoundSource (Private)

- (void) setDefaultValues;

@end

@implementation NPSoundSource

- (id) initWithName:(NSString *)newName
        sourceIndex:(NSUInteger)newSourceIndex
               alID:(ALuint)newALID
{
    self = [ super initWithName:newName ];

    sourceIndex = newSourceIndex;
    alID = newALID;
    currentSample = nil;
    currentStream = nil;
    locked = NO;

    [ self setDefaultValues ];

    return self;
}

- (void) dealloc
{
    [ self clear ];
    alDeleteSources(1, &alID);

    [ super dealloc ];
}

- (void) clear
{
    alSourceStop(alID);
    alSourcei(alID, AL_BUFFER, AL_NONE);

    if ( currentSample != nil )
    {
        DESTROY(currentSample);
    }

    if ( currentStream != nil )
    {
        [ currentStream stop ];
        [ currentStream setSoundSource:nil ];
        DESTROY(currentStream);
    }
}

- (void) reset
{

}

- (void) lock
{
    locked = YES;
}

- (void) unlock
{
    locked = NO;
}

- (BOOL) locked
{
    return locked;
}

- (void) pause
{
    alSourcePause(alID);
}

- (void) stop
{
    alSourceStop(alID);
}

- (void) resume
{
    alSourcePlay(alID);
}

- (void) playSample:(NPSoundSample *)sample
{
    NSAssert(sample != nil, @"No sample provided");

    // if we are already playing a sample we need to stop
    // the source in order to be able to clear the buffer
    // queue; this also works for streams, since buffers
    // added through alSourceQueueBuffers are removed too

    [ self clear ];
    
    ASSIGN(currentSample, sample);
    alSourcei(alID, AL_BUFFER, [ sample alID ]);
    alSourcef(alID, AL_ROLLOFF_FACTOR, [ sample range ]);
    alSourcePlay(alID);

    [ self setDefaultValues ];
}

- (void) playStream:(NPSoundStream *)stream
{
    NSAssert(stream != nil, @"No stream provided");

    [ self clear ];

    ASSIGN(currentStream, stream);
    [ currentStream setSoundSource:self ];
    [ currentStream start ];
    alSourcePlay(alID);

    [ self setDefaultValues ];
}

- (ALuint) alID
{
    return alID;
}

- (BOOL) paused
{
    ALint state;
    alGetSourcei(alID, AL_SOURCE_STATE, &state);

    return ( state == AL_PAUSED );
}

- (BOOL) playing
{
    ALint state;
    alGetSourcei(alID, AL_SOURCE_STATE, &state);

    return ((state == AL_PLAYING) || (state == AL_PAUSED));
}

- (BOOL) looping
{
    return looping;
}

- (void) setPosition:(const FVector3)newPosition
{
    position = newPosition;
    is3DSource = YES;
}

- (void) setVolume:(float)newVolume
{
    volume = newVolume;
}

- (void) setPitch:(float)newPitch
{
    pitch = newPitch;
}

- (void) setLooping:(BOOL)newLooping
{
    looping = newLooping;
}

- (void) updateSource
{
    if ( locked == YES )
    {
        return;
    }

    FVector3 velocity = fv3_vv_sub(&position, &positionLastFrame);
    fv3_sv_scale([[[ NPEngineCore instance ] timer ] reciprocalFrameTime ], &velocity);

    alSource3f(alID, AL_POSITION, position.x, position.y, position.z);
    alSource3f(alID, AL_VELOCITY, velocity.x, velocity.y, velocity.z);
    alSourcef(alID, AL_PITCH, pitch + pitchVariation);
    alSourcef(alID, AL_GAIN, volume + volumeVariation);

    if ( is3DSource == YES )
    {
        alSourcei(alID, AL_SOURCE_RELATIVE, AL_FALSE);
    }
    else
    {
        alSourcei(alID, AL_SOURCE_RELATIVE, AL_TRUE);
    }

    if ( currentSample != nil )
    {
        if ( looping == YES )
        {
            alSourcei(alID, AL_LOOPING, AL_TRUE);
        }
        else
        {
            alSourcei(alID, AL_LOOPING, AL_FALSE);
        }
    }

    if ( currentStream != nil )
    {
        [ currentStream setLooping:looping ];
    }
}

- (void) update
{
    ALint value;
    alGetSourcei(alID, AL_SOURCE_STATE, &value);

    if ( value == AL_PLAYING )
    {
        [ self updateSource ];

        if ( currentStream != nil )
        {
            [ currentStream update ];
        }
    }

    positionLastFrame = position;
}

@end

@implementation NPSoundSource (Private)

- (void) setDefaultValues
{
    fv3_v_init_with_zeros(&positionLastFrame);
    fv3_v_init_with_zeros(&position);

    pitch = volume = 1.0f;
    pitchVariation = volumeVariation = 0.0f;

    is3DSource = NO;
    looping = NO;
}

@end

