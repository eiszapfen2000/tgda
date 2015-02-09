#import "Core/NPEngineCore.h"
#import "NPEngineSound.h"
#import "NPListener.h"

@implementation NPListener

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    fv3_v_init_with_zeros(&listenerPositionLastFrame);
    fv3_v_init_with_zeros(&listenerPosition);
    fquat_set_identity(&listenerRotation);

    return self;
}

- (void) dealloc
{
    [ super dealloc ];
}

- (void) setListenerPosition:(FVector3)newListenerPosition
{
    listenerPosition = newListenerPosition;
}

- (void) setListenerOrientation:(FQuaternion)newListenerOrientation
{
    listenerRotation = newListenerOrientation;
}

- (void) update
{
    float volume = [[ NPEngineSound instance ] volume ];

    FVector3 velocity = fv3_vv_sub(&listenerPosition, &listenerPositionLastFrame);
    velocity = fv3_sv_scaled([[[ NPEngineCore instance ] timer ] reciprocalFrameTime ], &velocity);

    FVector3 forward = fquat_q_forward_vector(&listenerRotation);
    FVector3 up = fquat_q_up_vector(&listenerRotation);

    float alOrientation[6];
    alOrientation[0] = forward.x;
    alOrientation[1] = forward.y;
    alOrientation[2] = forward.z;
    alOrientation[3] = up.x;
    alOrientation[4] = up.y;
    alOrientation[5] = up.z;

    float alPosition[3];
    alPosition[0] = listenerPosition.x;
    alPosition[1] = listenerPosition.y;
    alPosition[2] = listenerPosition.z;

    float alVelocity[3];
    alVelocity[0] = velocity.x;
    alVelocity[1] = velocity.y;
    alVelocity[2] = velocity.z;

    // Update listener position in OpenAL.
    alListenerf(AL_GAIN, volume);
    alListenerfv(AL_POSITION, alPosition);
    alListenerfv(AL_ORIENTATION, alOrientation);
    alListenerfv(AL_VELOCITY, alVelocity);

    listenerPositionLastFrame = listenerPosition;
}


@end
