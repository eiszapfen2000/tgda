#import "NPSoundSample.h"
#import "NPSoundSource.h"
#import "NPSoundSources.h"

@interface NPSoundSources (Private)

- (BOOL) startupSources;
- (void) shutdownSources;

@end

@implementation NPSoundSources

- (id) init
{
    return [ self initWithName:@"NPEngine Sound Sources" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

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
    NPSoundSource * source;
    NSEnumerator * enumerator = [ sources objectEnumerator ];

    while (( source = [ enumerator nextObject ] ))
    {
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
    NPSoundSource * source;
    NSEnumerator * enumerator = [ sources objectEnumerator ];

    while (( source = [ enumerator nextObject ] ))
    {
        [ source pause ];
    }
}

- (void) stopAllSources
{
    NPSoundSource * source;
    NSEnumerator * enumerator = [ sources objectEnumerator ];

    while (( source = [ enumerator nextObject ] ))
    {
        [ source stop ];
    }
}

- (void) resumeAllSources
{
    NPSoundSource * source;
    NSEnumerator * enumerator = [ sources objectEnumerator ];

    while (( source = [ enumerator nextObject ] ))
    {
        [ source resume ];
    }
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

- (NPSoundSource *) play:(NPSoundSample *)sample
{
    NPSoundSource * source = [ self firstFreeSource ];
    if ( source != nil )
    {
        [ source play:sample ];
    }

    return source;
}

- (void) update
{
    NPSoundSource * source;
    NSEnumerator * enumerator = [ sources objectEnumerator ];

    while (( source = [ enumerator nextObject ] ))
    {
        [ source update ];
    }
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
                [[ NPSoundSource alloc ] initWithName:[NSString stringWithFormat:@"Source%lu", index]
                                               parent:self
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
