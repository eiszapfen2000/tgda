#import <vorbis/vorbisfile.h>
#import <Foundation/NSData.h>
#import "Log/NPLog.h"
#import "Core/Utilities/NSError+NPEngine.h"
#import "NPEngineSound.h"
#import "NPEngineSoundErrors.h"
#import "NPVorbisErrors.h"
#import "NPSoundSample.h"

@interface NPSoundSample (Private)

- (void) deleteALBuffer;
- (void) generateALBuffer;

@end

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

    file = nil;
    ready = NO;

    alID = AL_NONE;
    volume = 1.0f;
    length = 0.0f;
    range = 1.0f;

    return self;
}

- (void) dealloc
{
    [ self deleteALBuffer ];
    [ super dealloc ];
}

- (NSString *) fileName
{
    return file;
}

- (BOOL) ready
{
    return ready;
}

- (ALuint) alID
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

    alID = AL_NONE;
    volume = 1.0f;
    length = 0.0f;
    range = 1.0f;    

    SAFE_DESTROY(file);
    ready = NO;
}

- (BOOL) loadFromStream:(id <NPPStream>)stream 
                  error:(NSError **)error
{
    return NO;
}

- (BOOL) loadFromFile:(NSString *)fileName
                error:(NSError **)error
{
    [ self setName:fileName ];

    // open file
    FILE * cfile = fopen([fileName fileSystemRepresentation], "rb");
    if ( cfile == NULL )
    {
        return NO;
    }

    // feed file handle to ov_open
    OggVorbis_File oggFile;
    int resultCode = ov_open(cfile, &oggFile, NULL, 0);
    if ( resultCode < 0 )
    {
        if ( error != NULL )
        {
            *error = [ NPVorbisErrors vorbisOpenError:resultCode ];
        }

        fclose(cfile);
        return NO;
    }

    vorbis_info * info;
    info = ov_info(&oggFile, -1);
    length = ov_time_total(&oggFile, -1);

    NPLOG(@"Number of Streams: %ld", ov_streams(&oggFile));
    NPLOG(@"Number of Channels: %d", info->channels);
    NPLOG(@"Length in Seconds: %f", length);
    NPLOG(@"Sampling Rate: %ld", info->rate);
    NPLOG(@"Maximum Bit Rate: %ld", info->bitrate_upper);
    NPLOG(@"Minimum Bit Rate: %ld", info->bitrate_lower);
    NPLOG(@"Average Bit Rate: %ld", ov_bitrate(&oggFile, -1));

    ALsizei frequency = info->rate;
    ALenum format = AL_NONE;

    switch ( info->channels )
    {
        case 1:
        {
            format = AL_FORMAT_MONO16;
            break;
        }

        case 2:
        {
            format = AL_FORMAT_STEREO16;
            break;
        }

        default:
        {
            if ( error != NULL )
            {
                *error = [ NSError errorWithCode:NPVorbisNumberOfChannelsError
                                     description:NPVorbisNumberOfChannelsErrorString ];
            }

            return NO;
        }
    }

    NSMutableData * data = [ NSMutableData data ];

    #define BUFFER_SIZE     32768       // 32 KB buffers

    long bytesRead;
    int stream = -1;
    char buffer[BUFFER_SIZE];

    do
    {
        bytesRead = ov_read(&oggFile, buffer, BUFFER_SIZE, 0, 2, 1, &stream);

        if ( bytesRead < 0 )
        {
            if ( error != NULL )
            {
                *error = [ NPVorbisErrors vorbisReadError:bytesRead ];
            }

            return NO;
        }

        [ data appendBytes:buffer length:bytesRead ];
    }
    while ( bytesRead > 0 );

    #undef BUFFER_SIZE

    ov_clear(&oggFile);

    NPLOG(@"Uncompressed Size: %lu", [ data length ]);

    // generate OpenAL name
    [ self generateALBuffer ];

    // upload buffer data
    alBufferData(alID, format, [ data bytes ], [ data length ], frequency);

    // check if buffer upload went well
    if ( [[ NPEngineSound instance ] checkForALError:error ] == YES )
    {
        ready = YES;
    }

    return ready;
}

@end

@implementation NPSoundSample (Private)

- (void) deleteALBuffer
{
    if ( alID != AL_NONE )
    {
        alDeleteBuffers(1, &alID);
        alID = AL_NONE;
    }
}

- (void) generateALBuffer
{
    [ self deleteALBuffer ];
    alGenBuffers(1, &alID);
}

@end

