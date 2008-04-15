#include "prng.h"

#import "NPRandomNumberGenerator.h"

@implementation NPRandomNumberGenerator

- init
{
    return [ self initWithName:@"NPEngine Default Random Number Generator" ];

}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    return [ self initWithName:newName parent:newParent parameters:NP_RNG_DEFAULT];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent parameters:(NSString *)rngParameters
{
    self = [ super initWithName:newName parent:newParent ];

	char * rngDescription = (char*)[ rngParameters UTF8String ];
    randomNumberGenerator = prng_new(rngDescription);

    return self;
}

- (void) dealloc
{
	prng_free(randomNumberGenerator);

	[ super dealloc ];
}

- (Double) nextUniformFPRandomNumber
{
	return prng_get_next(randomNumberGenerator);
}

- (void) arrayOfUniformFPRandomNumbers:(Double *)array count:(UInt64)count
{
    prng_get_array(randomNumberGenerator, array, count);
}

- (ULong) nextUniformIntegerRandomNumber
{
	return prng_get_next_int(randomNumberGenerator);
}

- (void) reseed:(ULong)seed
{
	if ( prng_can_seed(randomNumberGenerator) )
	{
		prng_seed(randomNumberGenerator, seed);
	}
}

- (void) reset
{
	prng_reset(randomNumberGenerator);
}

- (NSString *) description
{
	return [ NSString stringWithCString:prng_long_name(randomNumberGenerator) encoding:NSUTF8StringEncoding ]; 
}

@end
