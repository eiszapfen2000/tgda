#import "AL/al.h"
#import "AL/alc.h"
#import "AL/alext.h"
#import "Core/NPObject/NPObject.h"

@interface NPEngineSound : NSObject < NPPObject >
{
    uint32_t objectID;
    NSString * name;

    ALCdevice * device;
    ALCcontext * context;

    Float volume;
}

+ (NPEngineSound *) instance;

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (void) setup;

- (Float) volume;
- (void) setVolume:(Float)newVolume;

- (void) checkForALErrors;
- (void) update;

@end
