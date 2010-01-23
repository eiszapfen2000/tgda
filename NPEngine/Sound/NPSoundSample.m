#import <vorbis/vorbisfile.h>
#import <sys/stat.h>
#import "NPSoundSample.h"
#import "NP.h"

@implementation NPSoundSample

- (id) init
{
    return [ self initWithName:@"Sound Sample" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    alID = UINT_MAX;
    volume = 1.0f;
    length = 0.0f;
    range = 1.0f;

    return self;
}

- (void) deleteALBuffer
{
    if ( alID > 0 && alID < UINT_MAX )
    {
        alDeleteBuffers(1, &alID);
        alID = UINT_MAX;
    }
}

- (void) dealloc
{
    [ self deleteALBuffer ];

    [ super dealloc ];
}

- (void) generateALBuffer
{
    [ self deleteALBuffer ];

    alGenBuffers(1, &alID);
}

- (UInt32) alID
{
    return alID;
}

- (Float) volume
{
    return volume;
}

- (Float) range
{
    return range;
}

- (Float) length
{
    return length;
}

- (void) clear
{
    [ self deleteALBuffer ];
}

- (BOOL) loadFromPath:(NSString *)path
{
    [ self setName:path ];

    FILE * file = fopen([path fileSystemRepresentation], "rb");
    if ( file == NULL )
    {
        NPLOG_ERROR(@"Unable to open file %@", path);
        return NO;
    }

    vorbis_info * info;
    OggVorbis_File oggFile;

    if ( ov_open(file, &oggFile, NULL, 0) < 0 )
    {
        NPLOG_ERROR(@"VorbisFile failed to open file %@", path);
        fclose(file);
        return NO;
    }

    info = ov_info(&oggFile, -1);

    NPLOG(@"Number of Streams: %ld", ov_streams(&oggFile));
    NPLOG(@"Number of Channels: %d", info->channels);
    NPLOG(@"Sampling Rate: %ld", info->rate);
    NPLOG(@"Maximum Bit Rate: %ld", info->bitrate_upper);
    NPLOG(@"Minimum Bit Rate: %ld", info->bitrate_lower);
    NPLOG(@"Average Bit Rate: %ld", ov_bitrate(&oggFile, -1));

    ALenum format;
    ALsizei size;
    ALsizei frequency;
    ALboolean loop;
    ALint bitDepth;

    if ( info->channels == 1 )
    {
        format = AL_FORMAT_MONO16;
    }
    else if ( info->channels == 2 )
    {
        format = AL_FORMAT_STEREO16;
    }

    frequency = info->rate;

    NSMutableData * data = [[ NSMutableData alloc ] init ];

    #define BUFFER_SIZE     32768       // 32 KB buffers

    long bytesRead;
    int stream;
    char buffer[BUFFER_SIZE];

    do
    {
        bytesRead = ov_read(&oggFile, buffer, BUFFER_SIZE, 0, 2, 1, &stream);

        [ data appendBytes:buffer length:bytesRead ];
    }
    while ( bytesRead > 0 );

    ov_clear(&oggFile);

    NPLOG(@"Uncompressed Size: %lu", [data length]);

    [ self generateALBuffer ];

    alBufferData(alID, format, [ data bytes ], [data length], frequency);

    [ data release ];

    return YES;
}

@end
