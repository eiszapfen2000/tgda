#import "AL/al.h"
#import "Core/NPObject/NPObject.h"
#import "Core/File/NPPPersistentObject.h"

@interface NPSoundSample : NPObject < NPPPersistentObject >
{
    ALuint alID;
    Float volume;
    Float range;
    Float length;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (ALuint) alID;
- (Float) volume;
- (Float) range;
- (Float) length;

- (void) clear;

@end
