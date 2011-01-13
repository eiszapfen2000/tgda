#import <vorbis/vorbisfile.h>
#import "AL/al.h"
#import "Core/NPObject/NPObject.h"
#import "Core/File/NPPPersistentObject.h"

@class NPSoundSource;

@interface NPSoundStream : NPObject < NPPPersistentObject >
{
    // Stream info
    OggVorbis_File oggStream;
    vorbis_info * oggInfo;
    vorbis_comment* oggComment;
    ALenum format;
    uint32_t bufferSize;
    uint32_t bufferLength;
    Float length;
    BOOL playing;
    BOOL loop;
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
- (void) setSoundSource:(NPSoundSource *)newSoundSource;

- (void) start;
- (void) stop;

- (void) update;

@end
