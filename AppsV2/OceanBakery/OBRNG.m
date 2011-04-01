#import "OBRNG.h"

@implementation OBRNG

- init
{
    return [ self initWithName:@"Default RNG" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parameters:NP_RNG_DEFAULT ];
}

- (id) initWithName:(NSString *)newName
         parameters:(NSString *)rngParameters
{
    self = [ super initWithName:newName ];

    char * p = (char *)[ rngParameters UTF8String ];
    randomNumberGenerator = prng_new(p);

    return self;
}

- (void) dealloc
{
	prng_free(randomNumberGenerator);

	[ super dealloc ];
}

- (double) nextUniformFPRandomNumber
{
	return prng_get_next(randomNumberGenerator);
}

- (NSUInteger) nextUniformIntegerRandomNumber
{
	return prng_get_next_int(randomNumberGenerator);
}

- (void) arrayOfUniformFPRandomNumbers:(double *)array
                                 count:(int32_t)count
{
    prng_get_array(randomNumberGenerator, array, count);
}

- (void) seed:(NSUInteger)seed
{
	if ( prng_can_seed(randomNumberGenerator) )
	{
		prng_seed(randomNumberGenerator, seed);
	}
    else
    {
        NSLog(@"%@: unable to seed", name);
    }
}

- (void) reset
{
	prng_reset(randomNumberGenerator);
}

- (NSString *) description
{
	return [ NSString stringWithCString:prng_long_name(randomNumberGenerator)
                               encoding:NSASCIIStringEncoding ]; 
}

@end
