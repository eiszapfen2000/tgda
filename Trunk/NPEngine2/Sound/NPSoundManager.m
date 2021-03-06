#import <Foundation/NSObject.h>
#import <Foundation/NSDictionary.h>
#import "Core/NPEngineCore.h"
#import "Core/File/NPLocalPathManager.h"
#import "NPSoundSample.h"
#import "NPSoundStream.h"
#import "NPSoundManager.h"

@implementation NPSoundManager

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    samples = [[ NSMutableDictionary alloc ] init ];
    streams = [[ NSMutableDictionary alloc ] init ];

    return self;
}

- (void) dealloc
{
    [ samples removeAllObjects ];
    [ streams removeAllObjects ];

    DESTROY(samples);
    DESTROY(streams);

    [ super dealloc ];
}

- (void) shutdown
{
    [ samples removeAllObjects ];
    [ streams removeAllObjects ];
}

- (NPSoundSample *) loadSampleFromFile:(NSString *)fileName
{
    NSString * absoluteFileName = 
        [[[ NPEngineCore instance ] localPathManager ] getAbsolutePath:fileName ];

    // check if we got a non-empty path
    if ( absoluteFileName == nil )
    {
        return nil;
    }

    NPSoundSample * sample = [ samples objectForKey:absoluteFileName ];

    if ( sample == nil )
    {
        NSError * error = nil;
        sample = [[ NPSoundSample alloc ] initWithName:@"" ];

        if ( [ sample loadFromFile:absoluteFileName error:&error ] == YES )
        {
            [ samples setObject:sample forKey:absoluteFileName ];
            [ sample release ];
        }
        else
        {
            DESTROY(sample);
        }
    }

    return sample;
}

- (NPSoundStream *) loadStreamFromFile:(NSString *)fileName
{
    NSString * absoluteFileName = 
        [[[ NPEngineCore instance ] localPathManager ] getAbsolutePath:fileName ];

    // check if we got a non-empty path
    if ( absoluteFileName == nil )
    {
        return nil;
    }

    NPSoundStream * stream = [ streams objectForKey:absoluteFileName ];

    if ( stream == nil )
    {
        NSError * error = nil;
        stream = [[ NPSoundStream alloc ] initWithName:@"" ];

        if ( [ stream loadFromFile:absoluteFileName error:&error ] == YES )
        {
            [ streams setObject:stream forKey:absoluteFileName ];
            [ stream release ];
        }
        else
        {
            DESTROY(stream);
        }
    }

    return stream;
}

- (void) update
{
    /*
    NPSoundStream * stream = nil;
    NSEnumerator * enumerator = [ streams objectEnumerator ];

    while (( stream = [ enumerator nextObject ] ))
    {
        [ stream update ];
    }
    */
}

@end
