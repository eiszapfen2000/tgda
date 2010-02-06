#import "NPSoundSample.h"
#import "NPSoundManager.h"
#import "NP.h"

@implementation NPSoundManager

- (id) init
{
    return [ self initWithName:@"NP Sound Manager" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

    samples = [[ NSMutableDictionary alloc ] init ];
    streams = [[ NSMutableDictionary alloc ] init ];

    return self;
}

- (void) dealloc
{
    [ samples removeAllObjects ];
    [ streams removeAllObjects ];

    [ samples release ];
    [ streams release ];

    [ super dealloc ];
}

- (NPSoundSample *) loadSampleFromPath:(NSString *)path
{
    NSString * absolutePath = [[[ NP Core ] pathManager ] getAbsoluteFilePath:path ];

    return [ self loadSampleFromAbsolutePath:absolutePath ];
}

- (NPSoundSample *) loadSampleFromAbsolutePath:(NSString *)path
{
    if ( [ path isEqual:@"" ] == NO )
    {
        NPSoundSample * sample = [ samples objectForKey:path ];

        if ( sample == nil )
        {
            NPLOG(@"%@: loading sound sample from %@", name, path);

            NPLOG_PUSH_PREFIX(@"  ");

            sample = [[ NPSoundSample alloc ] initWithName:@"" parent:self ];

            if ( [ sample loadFromPath:path ] == YES )
            {
                [ samples setObject:sample forKey:path ];
                [ sample release ];
            }
            else
            {
                [ sample release ];
                sample = nil;
            }

            NPLOG_POP_PREFIX();
        }

        return sample;
    }

    return nil;
}

- (NPSoundStream *) loadStreamFromPath:(NSString *)path
{
    NSString * absolutePath = [[[ NP Core ] pathManager ] getAbsoluteFilePath:path ];

    return [ self loadStreamFromAbsolutePath:absolutePath ];
}

- (NPSoundStream *) loadStreamFromAbsolutePath:(NSString *)path
{
    if ( [ path isEqual:@"" ] == NO )
    {
        NPSoundStream * stream = [ streams objectForKey:path ];

        if ( stream == nil )
        {
            NPLOG(@"%@: loading sound stream from %@", name, path);

            NPLOG_PUSH_PREFIX(@"  ");

            stream = [[ NPSoundStream alloc ] initWithName:@"" parent:self ];

            if ( [ stream loadFromPath:path ] == YES )
            {
                [ streams setObject:stream forKey:path ];
                [ stream release ];
            }
            else
            {
                [ stream release ];
                stream = nil;
            }

            NPLOG_POP_PREFIX();
        }

        return stream;
    }

    return nil;
}

- (void) update
{
    NSEnumerator * enumerator = [ streams objectEnumerator ];
    NPSoundStream * stream;

    while (( stream = [ enumerator nextObject ] ))
    {
        [ stream update ];
    }
}

@end
