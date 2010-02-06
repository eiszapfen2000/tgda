#import <vorbis/vorbisfile.h>
#import "AL/al.h"
#import "AL/alc.h"
#import "Core/NPObject/NPObject.h"

@class NPSoundChannel;

@interface NPSoundStream : NPObject
{
    // Stream info
    OggVorbis_File oggStream;
    vorbis_info * oggInfo;
    vorbis_comment* oggComment;
    ALenum format;
    UInt32 bufferSize;
    UInt32 bufferLength;
    Float length;

    // Other info
    Float position;
    Float volume;
    BOOL playing;

    NPSoundChannel * channel;
    UInt32 alBuffers[2];
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (void) dealloc;

- (BOOL) loadFromPath:(NSString *)path;

- (void) update;

@end
