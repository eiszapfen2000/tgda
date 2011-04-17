#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSProcessInfo.h>
#import "fftw3.h"
#import "Core/NPEngineCore.h"
#import "Core/File/NPFile.h"
#import "Core/File/NPLocalPathManager.h"
#import "Core/File/NSFileManager+NPEngine.h"
#import "OBPhillipsSpectrum.h"
#import "OBOceanSurface.h"
#import "OBOceanSurfaceGenerationConfiguration.h"
#import "OBOceanSurfaceManager.h"


@implementation OBOceanSurfaceManager

- (void) createFrequencySpectrumGenerators
{
    OBPhillipsSpectrum * phillips = [[ OBPhillipsSpectrum alloc ] initWithName:@"Phillips" ];
    [ frequencySpectrumGenerators setObject:phillips forKey:@"Phillips" ];
    [ phillips release ];
}

- (id) init
{
    return [ self initWithName:@"Ocean Surface Manager" ];
}

- (id) initWithName:(NSString *)newName
{
    self = [ super initWithName:newName ];

    frequencySpectrumGenerators = [[ NSMutableDictionary alloc ] init ];
    configurations = [[ NSMutableDictionary alloc ] init ];
    oceanSurfaces = [[ NSMutableArray alloc ] init ];

    processorCount = [[ NSProcessInfo processInfo ] processorCount ];
    fprintf(stdout, "%lu processors detected", processorCount);

    int result = fftw_init_threads();

    if ( result == 0 )
    {
        fprintf(stdout, "No FFTW thread support");
    }
    else
    {
        fprintf(stdout, "FFTW thread support up and running");
    }

    [ self createFrequencySpectrumGenerators ];

    return self;
}

- (void) dealloc
{
    [ oceanSurfaces removeAllObjects ];
    [ frequencySpectrumGenerators removeAllObjects ];
    [ configurations removeAllObjects ];

    DESTROY(oceanSurfaces);
    DESTROY(frequencySpectrumGenerators);
    DESTROY(configurations);

    fftw_cleanup_threads();

    [ super dealloc ];
}

- (id) frequencySpectrumGenerators
{
    return frequencySpectrumGenerators;
}

- (id) loadOceanSurfaceGenerationConfigurationFromPath:(NSString *)path
{
    NSString * absolutePath = [[[ NPEngineCore instance ] localPathManager ] getAbsolutePath:path ];

    return [ self loadOceanSurfaceGenerationConfigurationFromAbsolutePath:absolutePath ];
}

- (id) loadOceanSurfaceGenerationConfigurationFromAbsolutePath:(NSString *)path
{
    if ( [ path isEqual:@"" ] == NO )
    {
        OBOceanSurfaceGenerationConfiguration * config = [ configurations objectForKey:path ];

        if ( config == nil )
        {
            NSLog(@"%@: loading %@", name, path);

            OBOceanSurfaceGenerationConfiguration * config
                = [[ OBOceanSurfaceGenerationConfiguration alloc ]
                                                    initWithName:@""
                                                         manager:self ];

            if ( [ config loadFromFile:path error:NULL ] == YES )
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

- (void) saveOceanSurface:(OBOceanSurface *)oceanSurface atAbsolutePath:(NSString *)path
{
    if ( [[ NSFileManager defaultManager ] createEmptyFileAtPath:path ] == YES )
    {
        NPFile * file = [[ NPFile alloc ] initWithName:[oceanSurface name]
                                              fileName:path
                                                  mode:NpStreamWrite
                                                 error:NULL ];

        [ self saveOceanSurface:oceanSurface toFile:file ];
        [ file release ];
    }
    else
    {
        NSLog(@"%@ failed to create file %@", name, path);
    }
}

- (void) saveOceanSurface:(OBOceanSurface *)oceanSurface toFile:(NPFile *)file
{
    [ oceanSurface writeToStream:file error:NULL ];
}

- (void) processConfigurations
{
    NSEnumerator * configEnumerator = [ configurations objectEnumerator ];
    id config;

    while (( config = [ configEnumerator nextObject ] ))
    {
        fprintf(stdout, "Processing...\n");

        OBOceanSurface * tmp = [ config process ];

        fprintf(stdout, "Processed, now saving\n");

        NSString * path = [[[ NSFileManager defaultManager ] currentDirectoryPath ] stringByAppendingPathComponent:[config outputFileName]];

        [ self saveOceanSurface:tmp atAbsolutePath:path];
    }
}

@end
