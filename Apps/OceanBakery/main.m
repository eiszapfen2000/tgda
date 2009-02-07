#import <Foundation/Foundation.h>
#import "NP.h"
#import "OBOceanSurfaceGenerationConfiguration.h"
#import "OBOceanSurfaceManager.h"

int main (void)
{
    NSAutoreleasePool * pool = [[ NSAutoreleasePool alloc ] init ];
    [ NP Core ];

    id manager = [[ OBOceanSurfaceManager alloc ] init ];

    NSArray * arguments = [[ NSProcessInfo processInfo ] arguments ];
    if ( [ arguments count ] > 1 )
    {
        NSEnumerator * argumentsEnumerator = [ arguments objectEnumerator ];
        id file = [ argumentsEnumerator nextObject ] ;

        NSAutoreleasePool * innerPool = [[ NSAutoreleasePool alloc ] init ];

        while (( file = [ argumentsEnumerator nextObject ] ))
        {
            if ( [ file isAbsolutePath ] == YES && [[ NSFileManager defaultManager ] fileExistsAtPath:file ] == YES )
            {
                id config = [ manager loadFromAbsolutePath:file ];
            }
        }

        [ innerPool release ];

        [ manager processConfigurations ];
    }
    else
    {
        NSLog(@"No input file specified");
    }

    [ manager release ];
    [[ NP Core ] dealloc ];
    [ pool release ];

    return 0;
}
