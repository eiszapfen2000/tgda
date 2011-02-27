#import "AL/al.h"
#import "Core/NPObject/NPObject.h"
#import "Core/Protocols/NPPPersistentObject.h"

@interface NPSoundSample : NPObject < NPPPersistentObject >
{
    NSString * file;
    BOOL ready;

    ALuint alID;
    Float volume;
    Float range;
    Float length;
}

- (id) initWithName:(NSString *)newName;
- (void) dealloc;

- (ALuint) alID;
- (Float) volume;
- (Float) range;
- (Float) length;

- (void) clear;

@end
