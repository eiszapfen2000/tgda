#import <Foundation/Foundation.h>
#import "Log/NPLog.h"
#import "Log/NPLogFile.h"
#import "Core/NPEngineCore.h"
#import "Core/File/NPLocalPathManager.h"
#import "Core/File/NSFileManager+NPEngine.h"
#import "OBOceanSurfaceGenerationConfiguration.h"
#import "OBOceanSurfaceManager.h"

int main (void)
{
    NSAutoreleasePool * pool = [ NSAutoreleasePool new ];

    NPLogFile * logFile = [[ NPLogFile alloc ] init ];
    [[ NPLog instance ] addLogger:logFile ];

    [ NPEngineCore instance ];

    NSAutoreleasePool * innerPool = [ NSAutoreleasePool new ];

    OBOceanSurfaceManager * manager = [[ OBOceanSurfaceManager alloc ] init ];

    NSArray * arguments = [[ NSProcessInfo processInfo ] arguments ];
    NSUInteger numberOfArguments = [ arguments count ];

    if ( numberOfArguments > 1 )
    {
        for ( NSUInteger i = 1; i < numberOfArguments; i++ )
        {
            NSString * file = [ arguments objectAtIndex:i ];

            NSString * absolutePath
                = [[[ NPEngineCore instance ] localPathManager ] getAbsolutePath:file ];

            if ( absolutePath != nil )
            {
                fprintf(stdout, "Processing %s\n", [ absolutePath UTF8String ]);
                id config = [ manager loadOceanSurfaceGenerationConfigurationFromAbsolutePath:absolutePath ];
            }
            else
            {
                fprintf(stdout, "%s is not a file\n", [ file UTF8String ]);
            }
        }

        [ manager processConfigurations ];
    }
    else
    {
        fprintf(stdout, "No input file specified\n");
    }

    DESTROY(manager);
    DESTROY(innerPool);
    [[ NPEngineCore instance ] dealloc ];
    DESTROY(pool);

    return 0;
}
