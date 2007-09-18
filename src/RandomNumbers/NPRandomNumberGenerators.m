#include "prng.h"

#import "NPRandomNumberGenerators.h"

@implementation NPRandomNumberGenerator

- init
{
    self = [ super init ];

	char * rngDescription = (char*)[ NP_RNG_DEFAULT UTF8String ];

    randomNumberGenerator = prng_new(rngDescription);

    return self;
}

- initWithName
	: (NSString *) name
{
	self = [ super init ];

	char * rngDescription = (char*)[ name UTF8String ];

    randomNumberGenerator = prng_new(rngDescription);

    return self;
}

- (void) dealloc
{
	prng_free(randomNumberGenerator);

	[ super dealloc ];
}

- (NSString *) description
{
	return [ NSString stringWithCString: prng_long_name(randomNumberGenerator) encoding: NSUTF8StringEncoding ]; 
}

- (Double) nextUniformFPRandomNumber
{
	return prng_get_next(randomNumberGenerator);
}

- (void) arrayOfUniformFPRandomNumbers
    : (Double *) array
    : (UInt64) count
{
    prng_get_array(randomNumberGenerator, array, count);
}

- (ULong) nextUniformIntegerRandomNumber
{
	return prng_get_next_int(randomNumberGenerator);
}

- (void) reset
{
	prng_reset(randomNumberGenerator);
}

- (void) reseed
	: (ULong) seed
{
	if ( prng_can_seed(randomNumberGenerator) )
	{
		prng_seed(randomNumberGenerator, seed);
	}
}

@end
