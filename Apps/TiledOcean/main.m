#include <fftw3.h>
#import <AppKit/AppKit.h>

#import "RandomNumbers/NPRandomNumberGeneratorsManager.h"
#import "TOOceanSurface.h"
#import "Image/NPImage.h"

int main(int argc, const char *argv[])
{
    if(!fftw_init_threads())
    {
        NSLog(@"fftw failed");
    }
    else
    {
        NSLog(@"fftw threads initialised");
    }

    npimage_initialise();

    NSLog(@"brak");
    NPImage * image = [ [ NPImage alloc ] init ];
    NSLog(@"brak2");

    [ image loadImageFromFile:@"/usr/people/icicle/BoxWithOcean.tiff" withMipMaps:YES ];

        NSLog(@"done");

	NPRandomNumberGeneratorsManager * rngManager = [ [ NPRandomNumberGeneratorsManager alloc ] init ];

	NPRandomNumberGenerator * nrg = [ rngManager mersenneTwisterWithSeed: 1 ];
	NPRandomNumberGenerator * nrg2 = [ rngManager mersenneTwisterWithSeed: 1 ];

	//TOOceanSurfacePhillips * ocean = [ [ TOOceanSurfacePhillips alloc ] init: 4096 : 4096 : 100 : 100 : k ];

	//[ ocean setupH0 ];

    return  NSApplicationMain(argc, argv);
}


