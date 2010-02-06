#import "AL/al.h"
#import "AL/alc.h"
#import "AL/alext.h"
#import "Core/NPObject/NPObject.h"
#import "NPSoundChannel.h"
#import "NPSoundChannels.h"
#import "NPSoundManager.h"
#import "NPSoundWorld.h"

@interface NPEngineSound : NSObject < NPPObject >
{
    UInt32 objectID;
    NSString * name;

    ALCdevice * device;
    ALCcontext * context;

    NPSoundWorld * world;
    NPSoundChannels * channels;
    NPSoundManager * soundManager;

    Float volume;
}

+ (NPEngineSound *) instance;

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) setup;

- (NSString *) name;
- (NPObject *) parent;
- (UInt32) objectID;
- (NPSoundWorld *) world;
- (NPSoundChannels *) channels;
- (NPSoundManager *) soundManager;
- (Float) volume;
- (void) setName:(NSString *)newName;
- (void) setParent:(NPObject *)newParent;
- (void) setVolume:(Float)newVolume;

- (void) checkForALErrors;
- (void) update;

@end
