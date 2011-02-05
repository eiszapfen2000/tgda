#import <vorbis/vorbisfile.h>
#import "AL/al.h"
#import "Core/NPObject/NPObject.h"
#import "Core/Protocols/NPPPersistentObject.h"

@class NPSoundSource;

@interface NPSoundStream : NPObject < NPPPersistentObject >
{
    NSString * file;
    BOOL ready;

    // Stream info
    OggVorbis_File oggStream;
    vorbis_info * oggInfo;
    vorbis_comment* oggComment;
    ALenum format;
    long bufferSize;
    uint32_t bufferLength;
    Float length;
    BOOL playing;
    BOOL looping;
    ALuint alBuffers[2];
    // weak pointer
    NPSoundSource * soundSource;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (BOOL) playing;
- (BOOL) looping;
- (void) setLooping:(BOOL)newLooping;
- (void) setSoundSource:(NPSoundSource *)newSoundSource;

- (void) start;
- (void) stop;

- (void) update;

@end
