#import "OBOceanSurfaceManager.h"
#import "OBOceanSurfaceGenerationConfiguration.h"
#import "OBPhillipsSpectrum.h"
#import "fftw3.h"
#import "NP.h"

@implementation OBOceanSurfaceManager

- (void) createFrequencySpectrumGenerators
{
    OBPhillipsSpectrum * phillips = [[ OBPhillipsSpectrum alloc ] initWithName:@"Phillips" parent:self ];
    [ frequencySpectrumGenerators setObject:phillips forKey:@"Phillips" ];
    [ phillips release ];
}

- (id) init
{
    return [ self initWithName:@"Ocean Surface Manager" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    frequencySpectrumGenerators = [[ NSMutableDictionary alloc ] init ];
    configurations = [[ NSMutableDictionary alloc ] init ];
    currentConfiguration = nil;
    processorCount = [[ NSProcessInfo processInfo ] processorCount ];
    NPLOG(@"%@: %u processors detected",name,processorCount);

    int result = fftwf_init_threads();
    if ( result == 0 )
    {
        NPLOG_WARNING(@"%@: no fftw thread support",name);
    }
    else
    {
        NPLOG(@"%@: fftw thread support up and running",name);
    }

    [ self createFrequencySpectrumGenerators ];

    return self;
}

- (void) dealloc
{
    [ frequencySpectrumGenerators removeAllObjects ];
    [ frequencySpectrumGenerators release ];

    TEST_RELEASE(currentConfiguration);

    [ configurations removeAllObjects ];
    [ configurations release ];

    fftwf_cleanup_threads();

    [ super dealloc ];
}

- (id) frequencySpectrumGenerators
{
    return frequencySpectrumGenerators;
}

- (id) currentConfiguration
{
    return currentConfiguration;
}

- (void) setCurrentConfiguration:(id)newCurrentConfiguration
{
    ASSIGN(currentConfiguration,newCurrentConfiguration);
}

- (id) loadFromPath:(NSString *)path
{
    NSString * absolutePath = [[[ NP Core ] pathManager ] getAbsoluteFilePath:path ];

    return [ self loadFromAbsolutePath:absolutePath ];
}

- (id) loadFromAbsolutePath:(NSString *)path
{
    NPLOG(@"%@: loading %@", name, path);

    if ( [ path isEqual:@"" ] == NO )
    {
        OBOceanSurfaceGenerationConfiguration * config = [ configurations objectForKey:path ];

        if ( config == nil )
        {
            OBOceanSurfaceGenerationConfiguration * config = [[ OBOceanSurfaceGenerationConfiguration alloc ] initWithName:@"" parent:self ];

            if ( [ config loadFromPath:path ] == YES )
            {
                [ configurations setObject:config forKey:path ];
                [ config release ];

                return config;
            }
            else
            {
                [ config release ];

                return nil;
            }
        }

        return config;
    }

    return nil; 
}

- (void) processConfigurations
{
    NSEnumerator * configEnumerator = [ configurations objectEnumerator ];
    id config;

    while (( config = [ configEnumerator nextObject ] ))
    {
        [ config process ];
    }
}

@end
