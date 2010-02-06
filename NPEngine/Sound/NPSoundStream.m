#import "NPSoundStream.h"
#import "NP.h"

@implementation NPSoundStream

- (id) init
{
    return [ self initWithName:@"NP Sound Stream" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    channel = [[[ NP Sound ] channels ] reserveChannel ];

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
        [ channel stop ];

        alSourceUnqueueBuffers([channel alID], 2, alBuffers);
        [[ NP Sound ] checkForALErrors ];

        alDeleteBuffers(2, alBuffers);
        [[ NP Sound ] checkForALErrors ];

        alBuffers[0] = 0;
        alBuffers[1] = 0;
    }

    ov_clear(&oggStream);
}

- (void) dealloc
{
    [ self stopStreaming ];
    [ channel stop ];
    [ channel unlock ];
    channel = nil;

    [ super dealloc ];
}

- (BOOL) streamData:(ALuint)buffer
{
    long size = 0;
    long bytesRead;
    int bitStreamIndex;
    Char * bufferData = ALLOC_ARRAY(Char, bufferSize);

    while ( size < bufferSize )
    {
        bytesRead = ov_read(&oggStream, bufferData + size, bufferSize - size, 0, 2, 1, &bitStreamIndex);

        if ( bytesRead > 0 )
        {
            size = size + bytesRead;
        }
        else if ( bytesRead < 0 )
        {
            NPLOG_ERROR(@"%@: streamData - Error reading file", name);
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
    [[ NP Sound ] checkForALErrors ];

    SAFE_FREE(bufferData);

    return YES;
}

- (BOOL) startStreaming:(NSString *)path
{
    [ self stopStreaming ];

    FILE * file = fopen([path fileSystemRepresentation], "rb");
    if ( file == NULL )
    {
        NPLOG_ERROR(@"Unable to open file %@", path);
        return NO;
    }

    if ( ov_open(file, &oggStream, NULL, 0) < 0 )
    {
        NPLOG_ERROR(@"VorbisFile failed to open file %@", path);
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

    bufferSize = bufferLength * oggInfo->rate * oggInfo->channels * sizeof(UInt16);

    alGenBuffers(2, alBuffers);
    [[ NP Sound ] checkForALErrors ];

    ALuint channelALId = [ channel alID ];

    if ( alIsSource(channelALId) == AL_FALSE )
    {
        NPLOG_ERROR(@"Invalid channel for stream %@", name);
        return NO;
    }

    alSource3f(channelALId, AL_POSITION, 0.0f, 0.0f, 0.0f);
    alSource3f(channelALId, AL_VELOCITY, 0.0f, 0.0f, 0.0f);
    alSource3f(channelALId, AL_DIRECTION, 0.0f, 0.0f, 0.0f);
    alSourcef(channelALId, AL_GAIN, 1.0f);
    alSourcef(channelALId, AL_ROLLOFF_FACTOR, 0.0f);
    alSourcei(channelALId, AL_SOURCE_RELATIVE, AL_TRUE);

    if ( [ self streamData:alBuffers[0] ] == NO )
    {
        NPLOG_ERROR(@"%@ startStreaming - Could not initialise buffers", name);
        return NO;
    }

    if ( [ self streamData:alBuffers[1] ] == NO )
    {
        NPLOG_ERROR(@"%@ startStreaming - Could not initialise buffers", name);
        return NO;
    }

    alSourceQueueBuffers(channelALId, 2, alBuffers);
    alSourcePlay(channelALId);

    playing = YES;

    return YES;     
}

- (BOOL) loadFromPath:(NSString *)path
{
    [ self setName:path ];

    return [ self startStreaming:path ];
}

- (void) updateStream
{
    [[ NP Sound ] checkForALErrors ];

    ALint processed;
    ALuint channelALId = [ channel alID ];

    alGetSourcei(channelALId, AL_BUFFERS_PROCESSED, &processed);

    if ( processed > 0 )
    {
        do
        {
            ALuint buffer;            
            alSourceUnqueueBuffers(channelALId, 1, &buffer);
            [[ NP Sound ] checkForALErrors ];

            if ( [ self streamData:buffer ] == NO )
            {
                playing = NO;
                break;
            }

            alSourceQueueBuffers(channelALId, 1, &buffer);
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
