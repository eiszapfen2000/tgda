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

    return self;
}

- (void) dealloc
{
    [ channel stop ];
    [ channel unlock ];
    channel = nil;

    [ super dealloc ];
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

    NPLOG(@"Number of Streams: %ld", ov_streams(&oggStream));
    NPLOG(@"Number of Channels: %d", oggInfo->channels);
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

    alGenBuffers(2, alBuffers);
    [[ NP Sound ] checkForALErrors ];

    if ( alIsSource([channel alID]) == AL_FALSE )
    {
        NPLOG_ERROR(@"Invalid channel for stream %@", name);
        return NO;
    }

    return YES;     
}

- (BOOL) loadFromPath:(NSString *)path
{
    [ self setName:path ];

    return [ self startStreaming:path ];
}

@end
