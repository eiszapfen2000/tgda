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

- (id) loadSampleFromPath:(NSString *)path
{
    NSString * absolutePath = [[[ NP Core ] pathManager ] getAbsoluteFilePath:path ];

    return [ self loadSampleFromAbsolutePath:absolutePath ];
}

- (id) loadSampleFromAbsolutePath:(NSString *)path
{
    if ( [ path isEqual:@"" ] == NO )
    {
        NPSoundSample * sample = [ samples objectForKey:path ];

        if ( sample == nil )
        {
            NPLOG(@"%@: loading %@", name, path);

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

- (void) update
{
}

@end
