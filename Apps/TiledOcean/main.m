#include <fftw3.h>
#import <AppKit/AppKit.h>

#import "RandomNumbers/NPRandomNumberGenerators.h"
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

	NPRandomNumberGenerator * nrg = [[NPRandomNumberGenerator alloc] init];

	NSString * brak = [ NSString stringWithFormat: @"mt19937(%ul)", [ nrg nextUniformIntegerRandomNumber ] ];

	NSLog(brak);

	NPRandomNumberGenerator * nrg2 = [[NPRandomNumberGenerator alloc] initWithName: brak ];

	if(nrg2)
	{
		NSLog(@"juhuuuuu");
	}

	for ( int i = 0; i < 16; i++)
	{
		NSLog(@"%f",[nrg nextUniformFPRandomNumber]);
		NSLog(@"%f",[nrg2 nextUniformFPRandomNumber]);
	}

	NSLog(@"%@",nrg2);

	Vector2 k;
	k.x = k.y = 1.0;

	TOOceanSurfacePhillips * ocean = [ [ TOOceanSurfacePhillips alloc ] init: 8 : 8 : 100 : 100 : k ];

	[ ocean setupH0 ];

    return  NSApplicationMain(argc, argv);
}


