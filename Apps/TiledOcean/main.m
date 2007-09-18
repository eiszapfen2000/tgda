#include <fftw3.h>
#import <AppKit/AppKit.h>

#import "RandomNumbers/NPRandomNumberGeneratorsManager.h"
#import "TOOceanSurface.h"

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

	NSAutoreleasePool * pool = [NSAutoreleasePool new];

	NPRandomNumberGeneratorsManager * rngManager = [ [ NPRandomNumberGeneratorsManager alloc ] init ];

	NPRandomNumberGenerator * nrg = [ rngManager mersenneTwisterWithSeed: 1 ];
	NPRandomNumberGenerator * nrg2 = [ rngManager mersenneTwisterWithSeed: 1 ];

	Vector2 k;
	k.x = k.y = 1.0;

	//TOOceanSurfacePhillips * ocean = [ [ TOOceanSurfacePhillips alloc ] init: 4096 : 4096 : 100 : 100 : k ];

	//[ ocean setupH0 ];

    return  NSApplicationMain(argc, argv);
}


