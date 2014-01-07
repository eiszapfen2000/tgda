#import <Foundation/NSDictionary.h>
#import "Log/NPLog.h"
#import "Core/Container/NPAssetArray.h"
#import "Core/Utilities/NSError+NPEngine.h"
#import "NPEngineSound.h"
#import "NPEngineSoundErrors.h"
#import "NPVorbisErrors.h"
#import "NPSoundSource.h"
#import "NPSoundSources.h"
#import "NPSoundStream.h"

@interface NPSoundStream (Private)

- (BOOL) streamData:(ALuint)buffer;
- (BOOL) initialiseStream:(NSString *)fileName
                    error:(NSError **)error
                         ;
- (void) startStream;
- (void) updateStream;
- (void) stopStream;

@end

@implementation NPSoundStream

- (id) init
{
    return [ self initWithName:@"" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];
    [[[ NPEngineSound instance ] streams ] registerAsset:self ];

    file = nil;
    ready = NO;

    length = 0.0f;
    playing = NO;
    looping = NO;
    format = AL_NONE;
    bufferSize = 0;
    // number of seconds to hold in one buffer
    bufferLength = 4;
    alBuffers[0] = alBuffers[1] = AL_NONE;

    return self;
}

- (void) dealloc
{
    [ self stopStream ];
    [[[ NPEngineSound instance ] streams ] unregisterAsset:self ];
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

- (BOOL) playing
{
    return playing;
}

- (BOOL) looping
{
    return looping;
}

- (void) setLooping:(BOOL)newLooping
{
    looping = newLooping;
}

- (void) setSoundSource:(NPSoundSource *)newSoundSource
{
    soundSource = newSoundSource;
}

- (BOOL) loadFromStream:(id <NPPStream>)stream 
                  error:(NSError **)error
{
    return NO;
}

- (BOOL) loadFromFile:(NSString *)fileName
            arguments:(NSDictionary *)arguments
                error:(NSError **)error
{
    [ self setName:fileName ];

    if ( [ self initialiseStream:fileName error:error ] == YES )
    {
        ready = YES;
    }

    return ready;
}

- (void) start
{
    playing = YES;

    [ self startStream ];
}

- (void) stop
{
    [ self stopStream ];

    playing = NO;
}

- (void) update
{
    if ( playing == YES )
    {
        [ self updateStream ];
    }
}

@end

@implementation NPSoundStream (Private)

- (BOOL) streamData:(ALuint)buffer
{
    long size = 0;
    long bytesRead;
    int bitStreamIndex;
    char * bufferData = ALLOC_ARRAY(char, bufferSize);

    while ( size < bufferSize )
    {
        bytesRead = ov_read(&oggStream, bufferData + size, bufferSize - size, 0, 2, 1, &bitStreamIndex);

        if ( bytesRead > 0 )
        {
            size = size + bytesRead;
        }
        else if ( bytesRead < 0 )
        {
            NPLOG_ERROR([ NPVorbisErrors vorbisReadError:bytesRead ]);
            FREE(bufferData);
            return NO;
        }
        else
        {
            if ( looping == YES )
            {
                if ( ov_raw_seek(&oggStream, 0) == 0 )
                {
                    continue;
                }
            }

            break;
        }
    }

    if ( size == 0 )
    {
        FREE(bufferData);
        return NO;
    }

    alBufferData(buffer, format, bufferData, bufferSize, oggInfo->rate);
    [[ NPEngineSound instance] checkForALErrors ];
    FREE(bufferData);

    return YES;
}

- (BOOL) initialiseStream:(NSString *)path
                    error:(NSError **)error
{
    FILE * cfile = fopen([path fileSystemRepresentation], "rb");
    if ( cfile == NULL )
    {
        NSLog(@"Unable to open file %@", path);
        return NO;
    }

    int resultCode = ov_open(cfile, &oggStream, NULL, 0);
    if ( resultCode < 0 )
    {
        if ( error != NULL )
        {
            *error = [ NPVorbisErrors vorbisOpenError:resultCode ];
        }

        fclose(cfile);
        return NO;
    }

    oggInfo = ov_info(&oggStream, -1);
    length  = ov_time_total(&oggStream, -1);

    NPLOG(@"Number of Streams: %ld", ov_streams(&oggStream));
    NPLOG(@"Number of Channels: %d", oggInfo->channels);
    NPLOG(@"Length in Seconds: %f", length);
    NPLOG(@"Sampling Rate: %ld", oggInfo->rate);
    NPLOG(@"Maximum Bit Rate: %ld", oggInfo->bitrate_upper);
    NPLOG(@"Minimum Bit Rate: %ld", oggInfo->bitrate_lower);
    NPLOG(@"Average Bit Rate: %ld", ov_bitrate(&oggStream, -1));

    switch ( oggInfo->channels )
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

    // FIXME
    if ( length < (float)bufferLength )
    {
        bufferLength = (uint32_t)(ceil(length)) / 2;
    }
    
    bufferSize = bufferLength * oggInfo->rate * oggInfo->channels * sizeof(int16_t);

    alGenBuffers(2, alBuffers);
    [[ NPEngineSound instance] checkForALErrors ];

    if ( [ self streamData:alBuffers[0] ] == NO )
    {
        NSLog(@"%@ startStreaming - Could not initialise buffers", name);
        return NO;
    }

    if ( [ self streamData:alBuffers[1] ] == NO )
    {
        NSLog(@"%@ startStreaming - Could not initialise buffers", name);
        return NO;
    }

    return YES;
}

- (void) startStream
{
    if ( soundSource == nil )
    {
        NSLog(@"Stream %@ has no sound source", name);
        return;
    }

    ALuint sourceALID = [ soundSource alID ];

    if ( alIsSource(sourceALID) == AL_FALSE )
    {
        NSLog(@"Invalid source %@ for stream %@", [ soundSource name ], name);
        return;
    }

    alSourceQueueBuffers(sourceALID, 2, alBuffers);
}

- (void) updateStream
{
    ALint processed;
    ALuint sourceALID = [ soundSource alID ];

    alGetSourcei(sourceALID, AL_BUFFERS_PROCESSED, &processed);

    if ( processed > 0 )
    {
        do
        {
            ALuint buffer;            
            alSourceUnqueueBuffers(sourceALID, 1, &buffer);
            [[ NPEngineSound instance] checkForALErrors ];

            if ( [ self streamData:buffer ] == NO )
            {
                playing = NO;
                break;
            }

            alSourceQueueBuffers(sourceALID, 1, &buffer);
            processed = processed - 1;
        }
        while ( processed > 0 );
    }
}

- (void) stopStream
{
    if ((alBuffers[0] != AL_NONE) && (alBuffers[1] != AL_NONE))
    {
        alDeleteBuffers(2, alBuffers);
        alBuffers[0] = alBuffers[1] = AL_NONE;

        [[ NPEngineSound instance] checkForALErrors ];
    }

    ov_clear(&oggStream);
}

@end

