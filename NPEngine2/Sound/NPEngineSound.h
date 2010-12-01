#import "AL/al.h"
#import "AL/alc.h"
#import "AL/alext.h"
#import "Core/NPObject/NPPObject.h"
#import "NPSoundWorld.h"

@class NSError;

@interface NPEngineSound : NSObject < NPPObject >
{
    uint32_t objectID;

    ALCdevice * device;
    ALCcontext * context;

    NPSoundWorld * world;

    Float volume;
}

+ (NPEngineSound *) instance;

- (id) init;
- (void) dealloc;

- (BOOL) startup:(NSError **)error;
- (void) shutdown;

- (Float) volume;
- (void) setVolume:(Float)newVolume;
- (NPSoundWorld *) world;

- (BOOL) checkForALError:(NSError **)error;
- (void) update;

@end
