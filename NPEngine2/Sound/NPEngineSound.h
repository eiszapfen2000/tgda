#import "AL/al.h"
#import "AL/alc.h"
#import "AL/alext.h"
#import "Core/Basics/NpTypes.h"
#import "Core/Protocols/NPPObject.h"

@class NSError;
@class NPListener;
@class NPSoundSources;
@class NPSoundManager;

@interface NPEngineSound : NSObject < NPPObject >
{
    uint32_t objectID;

    ALCdevice * device;
    ALCcontext * context;

    NPListener * listener;
    NPSoundSources * sources;
    NPSoundManager * soundManager;

    Float volume;
}

+ (NPEngineSound *) instance;

- (id) init;
- (void) dealloc;

- (BOOL) startup;
- (void) shutdown;

- (Float) volume;
- (void) setVolume:(Float)newVolume;
- (NPListener *) listener;
- (NPSoundSources *) sources;
- (NPSoundManager *) soundManager;

- (BOOL) checkForALError:(NSError **)error;
- (void) checkForALErrors;
- (void) update;

@end
