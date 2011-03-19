#import "NPSoundSample.h"
#import "NPSoundSource.h"
#import "NPSoundSources.h"

@interface NPSoundSources (Private)

- (BOOL) startupSources;
- (void) shutdownSources;

@end

@implementation NPSoundSources

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    sources = [[ NSMutableArray alloc ] init ];

    return self;
}

- (void) dealloc
{
    [ sources removeAllObjects ];
    DESTROY(sources);

    [ super dealloc ];
}

- (BOOL) startup
{
    return [ self startupSources ];
}

- (void) shutdown
{
    [ self shutdownSources ];
}

- (NSUInteger) numberOfSources
{
    return [ sources count ];
}

- (NPSoundSource *) sourceAtIndex:(NSUInteger)index
{
    return [ sources objectAtIndex:index ];
}

- (NPSoundSource *) firstFreeSource
{
    NPSoundSource * source = nil;
    NSUInteger numberOfSources = [ sources count ];

    for ( NSUInteger i = 0; i < numberOfSources; i++ )
    {
        source = [ sources objectAtIndex:i ];

        if (( [ source playing ] == NO ) &&
            ( [ source locked  ] == NO ))
        {
            return source;
        }       
    }

    return nil;
}

- (void) pauseAllSources
{
    [ sources makeObjectsPerformSelector:@selector(pause) ];
}

- (void) stopAllSources
{
    [ sources makeObjectsPerformSelector:@selector(stop) ];
}

- (void) resumeAllSources
{
    [ sources makeObjectsPerformSelector:@selector(resume) ];
}

- (NPSoundSource *) reserveSource
{
    NPSoundSource * source = [ self firstFreeSource ];
    if ( source != nil )
    {
        [ source lock ];
    }

    return source;
}

- (NPSoundSource *) playSample:(NPSoundSample *)sample
{
    NPSoundSource * source = [ self firstFreeSource ];
    if ( source != nil )
    {
        [ source playSample:sample ];
    }

    return source;
}

- (NPSoundSource *) playStream:(NPSoundStream *)stream
{
    NPSoundSource * source = [ self firstFreeSource ];
    if ( source != nil )
    {
        [ source playStream:stream ];
    }

    return source;
} 


- (void) update
{
    [ sources makeObjectsPerformSelector:@selector(update) ];
}

@end

@implementation NPSoundSources (Private)

- (BOOL) startupSources
{
    ALuint alID;
    NSUInteger index = 0;
    BOOL outOfSources = NO;

    do
    {
        alGenSources(1, &alID);

        if ( alIsSource(alID) == AL_FALSE )
        {
            outOfSources = YES;
        }

        if ( alGetError() != AL_NO_ERROR )
        {
            outOfSources = YES;
        }

        if ( outOfSources == NO )
        {
            NPSoundSource * source = 
                [[ NPSoundSource alloc ]
                        initWithName:[NSString stringWithFormat:@"Source%lu", index]
                         sourceIndex:index
                                alID:alID ];

            [ sources addObject:source ];
            [ source release ];
        }

        index++;
    }
    while ( outOfSources == NO && index <= 31 );

    return YES;
}

- (void) shutdownSources
{
    [ self stopAllSources ];
    [ sources removeAllObjects ];
}

@end
