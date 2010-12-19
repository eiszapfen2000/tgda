#import "Core/NPEngineCore.h"
#import "NPSoundSample.h"
#import "NPSoundSource.h"

@interface NPSoundSource (Private)

- (void) setDefaultValues;
- (void) attachBuffer:(ALuint)bufferID;
- (void) detachBuffer;

@end

@implementation NPSoundSource

- (id) init
{
    return [ self initWithName:@"Sound Source" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    return [ self initWithName:newName 
                        parent:newParent
                   sourceIndex:ULONG_MAX
                          alID:UINT_MAX ];
}

- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject> )newParent
        sourceIndex:(NSUInteger)newSourceIndex
               alID:(ALuint)newALID
{
    self = [ super initWithName:newName parent:newParent ];

    sourceIndex = newSourceIndex;
    alID = newALID;
    currentSample = nil;
    locked = NO;

    [ self setDefaultValues ];

    return self;
}

- (void) dealloc
{
    TEST_RELEASE(currentSample);
    alDeleteSources(1, &alID);

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
    [ self detachBuffer ];
}

- (void) resume
{
    alSourcePlay(alID);
}

- (void) play:(NPSoundSample *)sample
{
    // Maybe convert to an NSAssert
    if ( sample == NULL )
    {
        return;
    }

    ASSIGN(currentSample, sample);
    [ self attachBuffer:[ sample alID ]];
    alSourcef(alID, AL_ROLLOFF_FACTOR, [ sample range ]);
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

- (void) setPosition:(const FVector3)newPosition
{
    position = newPosition;
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

    FVector3 velocity = fv3_vv_sub(&position, &positionLastFrame);
    fv3_sv_scale([[[ NPEngineCore instance ] timer ] reciprocalFrameTime ], &velocity);

    Float alPosition[3];
    alPosition[0] = position.x;
    alPosition[1] = position.y;
    alPosition[2] = position.z;

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
    ALint value;
    alGetSourcei(alID, AL_SOURCE_STATE, &value);

    if (value == AL_PLAYING)
    {
        [ self updateSource ];
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
    loop = NO;
}

- (void) attachBuffer:(ALuint)bufferID
{
    alSourcei(alID, AL_BUFFER, bufferID);
}

- (void) detachBuffer
{
    alSourcei(alID, AL_BUFFER, AL_NONE);
}

@end

