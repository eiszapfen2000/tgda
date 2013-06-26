#import "AL/al.h"
#import "Core/NPObject/NPObject.h"
#import "Core/Protocols/NPPPersistentObject.h"

@interface NPSoundSample : NPObject < NPPPersistentObject >
{
    NSString * file;
    BOOL ready;

    ALuint alID;
    float volume;
    float range;
    float length;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (ALuint) alID;
- (float) volume;
- (float) range;
- (float) length;

- (void) clear;

@end
