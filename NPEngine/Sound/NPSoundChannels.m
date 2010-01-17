#import "NPSoundSample.h"
#import "NPSoundChannel.h"
#import "NPSoundChannels.h"
#import "NP.h"

@implementation NPSoundChannels

- (id) init
{
    return [ self initWithName:@"Sound Channels" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    channels = [[ NSMutableArray alloc ] init ];

    UInt32 alID;
    UInt32 index = 0;
    BOOL outOfChannels = NO;

    do
    {
        alGenSources(1, &alID);

        if ( alIsSource(alID) == AL_FALSE )
        {
            outOfChannels = YES;
        }

        if ( alGetError() != AL_NO_ERROR )
        {
            outOfChannels = YES;
        }

        if ( outOfChannels == NO )
        {
            NPSoundChannel * channel = 
                [[ NPSoundChannel alloc ] initWithName:[NSString stringWithFormat:@"Channel%d", index]
                                                parent:self
                                          channelIndex:index
                                                  alID:alID ];

            [ channels addObject:channel ];
            [ channel release ];
        }

        index++;
    }
    while ( outOfChannels == NO && index <= 127 );

    return self;
}

- (void) dealloc
{
    [ channels removeAllObjects ];
    [ channels release ];

    [ super dealloc ];
}

- (void) pauseAllChannels
{
    NSEnumerator * enumerator = [ channels objectEnumerator ];
    NPSoundChannel * channel;

    while (( channel = [ enumerator nextObject ] ))
    {
        [ channel pause ];
    }
}

- (void) stopAllChannels
{
    NSEnumerator * enumerator = [ channels objectEnumerator ];
    NPSoundChannel * channel;

    while (( channel = [ enumerator nextObject ] ))
    {
        [ channel stop ];
    }
}

- (void) resumeAllChannels
{
    NSEnumerator * enumerator = [ channels objectEnumerator ];
    NPSoundChannel * channel;

    while (( channel = [ enumerator nextObject ] ))
    {
        [ channel resume ];
    }
}

- (NPSoundChannel *) play:(NPSoundSample *)sample
{
    NPSoundChannel * result = [ channels objectAtIndex:0 ];
    [ result play:sample ];

    return result;
}

- (void) update
{
    NSEnumerator * enumerator = [ channels objectEnumerator ];
    NPSoundChannel * channel;

    while (( channel = [ enumerator nextObject ] ))
    {
        [ channel update ];
    }
}

@end
