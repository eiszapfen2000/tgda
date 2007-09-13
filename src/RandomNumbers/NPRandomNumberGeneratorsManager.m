#import "NPRandomNumberGeneratorsManager.h"

@implementation NPRandomNumberGeneratorsManager

- init
{
	self = [ super init ];

	fixedParameterGeneratorNames = [ [ NSSet alloc ] initWithObjects: NP_RNG_TT800, NP_RNG_CTG, NP_RNG_MRG, NP_RNG_CMRG, nil ];

	generators = [ [ NSMutableArray alloc ] init ];

	return self;
}

- (NPRandomNumberGenerator *) fixedParameterGeneratorWithString: (NSString *) name;
{
	NPRandomNumberGenerator * generator = nil;

	if ( [ fixedParameterGeneratorNames containsObject: name ] )
	{
		generator = [ [ NPRandomNumberGenerator alloc ] initWithName: name ];

		[ generators addObject: generator ];

		[ generator release ];
	}
    else
    {
        NSLog(@"Wrong rng name, returning nil");
    }

	return generator;
}

- (NPRandomNumberGenerator *) mersenneTwisterWithSeed: (ULong) seed
{
    NSString * name = [ [ NSString alloc ] initWithFormat: @"mt19937(%ul)", seed ];

    NPRandomNumberGenerator * generator = [ [ NPRandomNumberGenerator alloc ] initWithName: name ];

	[ generators addObject: generator ];

	[ generator release ];

    return generator;
}

- (NPRandomNumberGenerator *) lcgGenerator
{
}

- (NPRandomNumberGenerator *) lcgGeneratorWithParameters
    : (ULong) periodLength
    : (ULong) seed
    : (ULong) a
    : (ULong) b
{
    NSString * name = [ [ NSString alloc ] initWithFormat: @"lcg(%ul,%ul,%ul,%ul)", periodLength, a, b, seed ];

    NPRandomNumberGenerator * generator = [ [ NPRandomNumberGenerator alloc ] initWithName: name ];

	[ generators addObject: generator ];

	[ generator release ];

    return generator;
}


- (NPRandomNumberGenerator *) icgGenerator
{
}

- (NPRandomNumberGenerator *) icgGeneratorWithParameters
    : (ULong) periodLength
    : (ULong) seed
    : (ULong) a
    : (ULong) b
{
    NSString * name = [ [ NSString alloc ] initWithFormat: @"icg(%ul,%ul,%ul,%ul)", periodLength, a, b, seed ];

    NPRandomNumberGenerator * generator = [ [ NPRandomNumberGenerator alloc ] initWithName: name ];

	[ generators addObject: generator ];

	[ generator release ];

    return generator;
}

- (NPRandomNumberGenerator *) eicgGenerator
{
}

- (NPRandomNumberGenerator *) eicgGeneratorWithParameters
    : (ULong) periodLength
    : (ULong) seed
    : (ULong) a
    : (ULong) b
{
    NSString * name = [ [ NSString alloc ] initWithFormat: @"eicg(%ul,%ul,%ul,%ul)", periodLength, a, b, seed ];

    NPRandomNumberGenerator * generator = [ [ NPRandomNumberGenerator alloc ] initWithName: name ];

	[ generators addObject: generator ];

	[ generator release ];

    return generator;
}

- (NPRandomNumberGenerator *) meicgGenerator
{
}

- (NPRandomNumberGenerator *) meicgGeneratorWithParameters
    : (ULong) periodLength
    : (ULong) seed
    : (ULong) a
    : (ULong) b
{
    NSString * name = [ [ NSString alloc ] initWithFormat: @"meicg(%ul,%ul,%ul,%ul)", periodLength, a, b, seed ];

    NPRandomNumberGenerator * generator = [ [ NPRandomNumberGenerator alloc ] initWithName: name ];

	[ generators addObject: generator ];

	[ generator release ];

    return generator;
}

- (NPRandomNumberGenerator *) dicgGenerator
{
}

- (NPRandomNumberGenerator *) dicgGeneratorWithParameters
    : (ULong) periodExponent
    : (ULong) seed
    : (ULong) a
    : (ULong) b
{
    NSString * name = [ [ NSString alloc ] initWithFormat: @"dicg(%ul,%ul,%ul,%ul)", periodExponent, a, b, seed ];

    NPRandomNumberGenerator * generator = [ [ NPRandomNumberGenerator alloc ] initWithName: name ];

	[ generators addObject: generator ];

	[ generator release ];

    return generator;
}

- (NPRandomNumberGenerator *) qcgGenerator
{
}

- (NPRandomNumberGenerator *) qcgGeneratorWithParameters
    : (ULong) periodLength
    : (ULong) seed
    : (ULong) a
    : (ULong) b
    : (ULong) c
{
    NSString * name = [ [ NSString alloc ] initWithFormat: @"qcg(%ul,%ul,%ul,%ul,%ul)", periodLength, a, b, c, seed ];

    NPRandomNumberGenerator * generator = [ [ NPRandomNumberGenerator alloc ] initWithName: name ];

	[ generators addObject: generator ];

	[ generator release ];

    return generator;
}

- (void) dealloc
{
	[ generators release ];

	[ super dealloc ];
}

@end
