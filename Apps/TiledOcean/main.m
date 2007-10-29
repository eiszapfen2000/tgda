#include <fftw3.h>
#import <AppKit/AppKit.h>

#import "RandomNumbers/NPRandomNumberGeneratorsManager.h"
#import "TOOceanSurface.h"
#import "Math/Vector.h"

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

    npmath_vector_initialise();
    //Vector2 * v2 = npfreenode_alloc(NP_VECTOR2_FREELIST);
    //Vector3 * v3 = npfreenode_alloc(NP_VECTOR3_FREELIST);
    //Vector4 * v4 = npfreenode_alloc(NP_VECTOR4_FREELIST);

    Vector2 * v2 = v2_alloc_init();
    Vector3 * v3 = v3_alloc_init();
//    Vector4 * v4 = v4_alloc_init();

    NSLog(@"%f %f %f %f %f",V_X(*v2),V_Y(*v2),V_X(*v3),V_Y(*v3),V_Z(*v3));


	NSAutoreleasePool * pool = [NSAutoreleasePool new];

	NPRandomNumberGeneratorsManager * rngManager = [ [ NPRandomNumberGeneratorsManager alloc ] init ];

	NPRandomNumberGenerator * nrg = [ rngManager mersenneTwisterWithSeed: 1 ];
	NPRandomNumberGenerator * nrg2 = [ rngManager mersenneTwisterWithSeed: 1 ];

	//TOOceanSurfacePhillips * ocean = [ [ TOOceanSurfacePhillips alloc ] init: 4096 : 4096 : 100 : 100 : k ];

	//[ ocean setupH0 ];

    return  NSApplicationMain(argc, argv);
}


