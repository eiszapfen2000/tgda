#import <Foundation/Foundation.h>
#import "NP.h"
#import "OBOceanSurfaceGenerationConfiguration.h"
#import "OBOceanSurfaceManager.h"

int main (void)
{
    NSAutoreleasePool * pool = [[ NSAutoreleasePool alloc ] init ];
    [ NP Core ];
    NSAutoreleasePool * innerPool = [[ NSAutoreleasePool alloc ] init ];

    //NSLog([[ NSBundle mainBundle ] bundlePath ]);

    OBOceanSurfaceManager * manager = [[ OBOceanSurfaceManager alloc ] init ];

    NSArray * arguments = [[ NSProcessInfo processInfo ] arguments ];
    if ( [ arguments count ] > 1 )
    {
        NSEnumerator * argumentsEnumerator = [ arguments objectEnumerator ];
        id file = [ argumentsEnumerator nextObject ];

        while (( file = [ argumentsEnumerator nextObject ] ))
        {
            if ( [ file isAbsolutePath ] == YES && [[ NSFileManager defaultManager ] isFile:file ] == YES )
            {
                id config = [ manager loadOceanSurfaceGenerationConfigurationFromAbsolutePath:file ];
            }
            else
            {
                NSLog(@"%@ is not a file", file);
            }
        }

        [ manager processConfigurations ];
    }
    else
    {
        NSLog(@"No input file specified");
    }

    [ manager release ];

    [ innerPool release ];
    [[ NP Core ] dealloc ];
    [ pool release ];

    return 0;
}
