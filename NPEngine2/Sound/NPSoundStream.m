#include <unistd.h>
#import "Log/NPLog.h"
#import "NPEngineSound.h"
#import "NPSoundSource.h"
#import "NPSoundSources.h"
#import "NPSoundStream.h"

@implementation NPSoundStream

- (id) init
{
    return [ self initWithName:@"NPEngine Sound Stream" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    source = [[[ NPEngineSound instance ] sources ] reserveSource ];

    length = 0.0f;
    position = 0.0f;
    volume = 1.0f;
    playing = NO;

    alBuffers[0] = alBuffers[1] = 0;

    bufferSize = 0;
    bufferLength = 4;

    return self;
}

- (void) stopStreaming
{
    playing = NO;

    if ( alBuffers[0] > 0 && alBuffers[1] > 0 )
    {
        [ source stop ];

        ALint q, p;
        alGetSourcei([source alID], AL_BUFFERS_QUEUED, &q);
        alGetSourcei([source alID], AL_BUFFERS_PROCESSED, &p);

        ALint * queuedBuffers = ALLOC_ARRAY(ALint, q);
        alGetSourceiv([source alID], AL_BUFFER, queuedBuffers);

        for (int32_t i = 0; i < q; i++ )
        {
            ALuint bufferID = (ALuint)(queuedBuffers[i]);
            alSourceUnqueueBuffers([source alID], 1, &bufferID);

            [[ NPEngineSound instance] checkForALErrors ];
        }

        alDeleteBuffers(2, alBuffers);
        [[ NPEngineSound instance] checkForALErrors ];

        alBuffers[0] = 0;
        alBuffers[1] = 0;
    }

    ov_clear(&oggStream);
}

- (void) dealloc
{
    [ self stopStreaming ];
    [ source stop ];
    [ source unlock ];
    source = nil;

    [ super dealloc ];
}

- (BOOL) playing
{
    return playing;
}

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
            NSLog(@"%@: streamData - Error reading file", name);
            return NO;
        }
        else
        {
            break;
        }
    }

    if ( size == 0 )
    {
        SAFE_FREE(bufferData);
        return NO;
    }

    alBufferData(buffer, format, bufferData, bufferSize, oggInfo->rate);
    [[ NPEngineSound instance] checkForALErrors ];
    SAFE_FREE(bufferData);

    return YES;
}

- (BOOL) startStreaming:(NSString *)path
{
    [ self stopStreaming ];

    FILE * file = fopen([path fileSystemRepresentation], "rb");
    if ( file == NULL )
    {
        NSLog(@"Unable to open file %@", path);
        return NO;
    }

    if ( ov_open(file, &oggStream, NULL, 0) < 0 )
    {
        NSLog(@"VorbisFile failed to open file %@", path);
        fclose(file);
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

    if ( oggInfo->channels == 1 )
    {
        format = AL_FORMAT_MONO16;
    }
    else if ( oggInfo->channels == 2 )
    {
        format = AL_FORMAT_STEREO16;
    }

    if ( length < (float)bufferLength )
    {
        bufferLength = (uint32_t)(ceil(length)) / 2;
    }

    bufferSize = bufferLength * oggInfo->rate * oggInfo->channels * sizeof(uint16_t);

    alGenBuffers(2, alBuffers);
    [[ NPEngineSound instance] checkForALErrors ];

    ALuint sourceALID = [ source alID ];

    if ( alIsSource(sourceALID) == AL_FALSE )
    {
        NSLog(@"Invalid channel for stream %@", name);
        return NO;
    }

    alSource3f(sourceALID, AL_POSITION, 0.0f, 0.0f, 0.0f);
    alSource3f(sourceALID, AL_VELOCITY, 0.0f, 0.0f, 0.0f);
    alSource3f(sourceALID, AL_DIRECTION, 0.0f, 0.0f, 0.0f);
    alSourcef(sourceALID, AL_GAIN, 1.0f);
    alSourcef(sourceALID, AL_ROLLOFF_FACTOR, 0.0f);
    alSourcei(sourceALID, AL_SOURCE_RELATIVE, AL_TRUE);

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

    alSourceQueueBuffers(sourceALID, 2, alBuffers);
    alSourcePlay(sourceALID);

    playing = YES;

    return YES;     
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

    return [ self startStreaming:fileName ];
}

- (void) updateStream
{
    ALint processed;
    ALuint sourceALID = [ source alID ];

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

- (void) update
{
    if ( playing == YES )
    {
        [ self updateStream ];
    }
}

@end
