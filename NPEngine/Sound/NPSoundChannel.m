#import "NPSoundSample.h"
#import "NPSoundChannel.h"
#import "NP.h"

@implementation NPSoundChannel

- (id) init
{
    return [ self initWithName:@"Sound Channel" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    return [ self initWithName:newName 
                        parent:newParent
                  channelIndex:UINT_MAX
                          alID:UINT_MAX ];
}

- (void) setDefaultValues
{
    fv3_v_init_with_zeros(position);
    fv3_v_init_with_zeros(positionLastFrame);

    pitch = volume = 1.0f;
    pitchVariation = volumeVariation = 0.0f;

    is3DSource = NO;
    loop = NO;
}

- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject> )newParent
       channelIndex:(UInt32)newChannelIndex
               alID:(UInt32)newALID
{
    self = [ super initWithName:newName parent:newParent ];

    channelIndex = newChannelIndex;
    alID = newALID;
    position = fv3_alloc_init();
    positionLastFrame = fv3_alloc_init();

    currentSample = nil;

    locked = NO;

    [ self setDefaultValues ];

    return self;
}

- (void) dealloc
{
    TEST_RELEASE(currentSample);

    position = fv3_free(position);
    positionLastFrame = fv3_free(positionLastFrame);

    [ super dealloc ];
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

- (void) play:(NPSoundSample *)sample
{
    if ( sample == NULL )
    {
        return;
    }

    ASSIGN(currentSample, sample);

    alSourcei(alID, AL_BUFFER, [ sample alID ]);
    alSourcef(alID, AL_ROLLOFF_FACTOR, [ sample range ]);
    alSourcePlay(alID);

    [ self setDefaultValues ];
}

- (UInt32) alID
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

- (void) setPosition:(const FVector3 const *)newPosition
{
    fv3_vv_init_with_fv3(position, newPosition);
    is3DSource = YES;
}

- (void) setVolume:(Float)newVolume
{
    volume = newVolume;
}

- (void) setPitch:(Float)newPitch
{
    pitch = newPitch;
}

- (void) setLooping:(BOOL)newLooping
{
    loop = newLooping;
}

- (void) updateSource
{
    if ( locked == YES )
    {
        return;
    }

    FVector3 velocity = fv3_vv_sub(position, positionLastFrame);
    fv3_sv_scale([[[ NP Core ] timer ] reciprocalFrameTime ], &velocity);

    Float alPosition[3];
    alPosition[0] = position->x;
    alPosition[1] = position->y;
    alPosition[2] = position->z;

    Float alVelocity[3];
    alVelocity[0] = velocity.x;
    alVelocity[1] = velocity.y;
    alVelocity[2] = velocity.z;

    alSourcefv(alID, AL_POSITION, alPosition);
    alSourcefv(alID, AL_VELOCITY, alVelocity);
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

    if ( loop == YES )
    {
        alSourcei(alID, AL_LOOPING, AL_TRUE);
    }
    else
    {
        alSourcei(alID, AL_LOOPING, AL_FALSE);
    }
}

- (void) update
{
    Int32 value;
    alGetSourcei(alID, AL_SOURCE_STATE, &value);

    if (value == AL_PLAYING)
    {
        [ self updateSource ];
    }

    fv3_vv_init_with_fv3(positionLastFrame, position);
}

@end


