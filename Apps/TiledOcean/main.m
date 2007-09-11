#include <fftw3.h>
#import <AppKit/AppKit.h>

#import "RandomNumbers/NPRandomNumberGenerators.h"

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

    return  NSApplicationMain(argc, argv);
}


