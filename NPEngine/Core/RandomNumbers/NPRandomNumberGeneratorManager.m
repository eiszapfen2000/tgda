#import "NPRandomNumberGeneratorManager.h"
#import "NPRandomNumberGenerator.h"
#import "NPGaussianRandomNumberGenerator.h"

#import "NP.h"

@implementation NPRandomNumberGeneratorManager

- init
{
    return [ self initWithName:@"NPEngine Random Number Generator Manager" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    self = [ super initWithName:newName parent:newParent ];

	fixedParameterGeneratorNames = [[ NSSet alloc ] initWithObjects: NP_RNG_TT800, NP_RNG_CTG, NP_RNG_MRG, NP_RNG_CMRG, nil ];
	generators = [[ NSMutableArray alloc ] init ];

    return self;
}

- (void) dealloc
{
    [ generators removeAllObjects ];
	[ generators release ];

    [ fixedParameterGeneratorNames release ];

	[ super dealloc ];
}

- (NPGaussianRandomNumberGenerator *) gaussianGenerator
{
    NPGaussianRandomNumberGenerator * generator = [[ NPGaussianRandomNumberGenerator alloc ] initWithName:@"Gaussian" parent:self ];
	[ generators addObject:generator ];

    return [ generator autorelease ];
}

- (NPGaussianRandomNumberGenerator *) gaussianGeneratorWithFirstGenerator:(NPRandomNumberGenerator *)firstGenerator
                                                       andSecondGenerator:(NPRandomNumberGenerator *)secondGenerator
{
    NPGaussianRandomNumberGenerator * generator = [[ NPGaussianRandomNumberGenerator alloc ] initWithName:@"Gaussian" 
                                                                                                   parent:self
                                                                                           firstGenerator:firstGenerator
                                                                                          secondGenerator:secondGenerator ];
	[ generators addObject:generator ];

    return [ generator autorelease ];
}


- (NPRandomNumberGenerator *) fixedParameterGeneratorWithRNGName:(NSString *)rngName;
{
	NPRandomNumberGenerator * generator = nil;

	if ( [ fixedParameterGeneratorNames containsObject:rngName ] == YES )
	{
		generator = [[ NPRandomNumberGenerator alloc ] initWithName:rngName parent:self parameters:rngName ];
		[ generators addObject:generator ];
		[ generator release ];
	}
    else
    {
        NPLOG_WARNING(@"Invalid fixed parameter rng name %@, returning nil",rngName);
    }

	return generator;
}

- (NPRandomNumberGenerator *) mersenneTwisterWithSeed:(ULong)seed
{
    NSString * parameters = [ NSString stringWithFormat: @"mt19937(%ul)", seed ];

    NPRandomNumberGenerator * generator = [[ NPRandomNumberGenerator alloc ] initWithName:@"MersenneTwister" parent:self parameters:parameters ];
	[ generators addObject:generator ];

    return [ generator autorelease ];
}

- (NPRandomNumberGenerator *) lcgGenerator
{
    return nil;
}

- (NPRandomNumberGenerator *) lcgGeneratorWithParameters
    :(ULong)periodLength
    :(ULong)seed
    :(ULong)a
    :(ULong)b
{
    NSString * parameters = [ NSString stringWithFormat: @"lcg(%ul,%ul,%ul,%ul)", periodLength, a, b, seed ];

    NPRandomNumberGenerator * generator = [[ NPRandomNumberGenerator alloc ] initWithName:@"lcg" parent:self parameters:parameters ];
	[ generators addObject:generator ];

    return [ generator autorelease ];
}


- (NPRandomNumberGenerator *) icgGenerator
{
    return nil;
}

- (NPRandomNumberGenerator *) icgGeneratorWithParameters
    :(ULong)periodLength
    :(ULong)seed
    :(ULong)a
    :(ULong)b
{
    NSString * parameters = [ NSString stringWithFormat: @"icg(%ul,%ul,%ul,%ul)", periodLength, a, b, seed ];

    NPRandomNumberGenerator * generator = [[ NPRandomNumberGenerator alloc ] initWithName:@"icg" parent:self parameters:parameters ];
	[ generators addObject:generator ];

    return [ generator autorelease ];
}

- (NPRandomNumberGenerator *) eicgGenerator
{
    return nil;
}

- (NPRandomNumberGenerator *) eicgGeneratorWithParameters
    :(ULong)periodLength
    :(ULong)seed
    :(ULong)a
    :(ULong)b
{
    NSString * parameters = [ NSString stringWithFormat: @"eicg(%ul,%ul,%ul,%ul)", periodLength, a, b, seed ];

    NPRandomNumberGenerator * generator = [[ NPRandomNumberGenerator alloc ] initWithName:@"eicg" parent:self parameters:parameters ];
	[ generators addObject:generator ];

    return [ generator autorelease ];
}

- (NPRandomNumberGenerator *) meicgGenerator
{
    return nil;
}

- (NPRandomNumberGenerator *) meicgGeneratorWithParameters
    :(ULong)periodLength
    :(ULong)seed
    :(ULong)a
    :(ULong)b
{
    NSString * parameters = [ NSString stringWithFormat: @"meicg(%ul,%ul,%ul,%ul)", periodLength, a, b, seed ];

    NPRandomNumberGenerator * generator = [[ NPRandomNumberGenerator alloc ] initWithName:@"meicg" parent:self parameters:parameters ];
	[ generators addObject:generator ];

    return [ generator autorelease ];
}

- (NPRandomNumberGenerator *) dicgGenerator
{
    return nil;
}

- (NPRandomNumberGenerator *) dicgGeneratorWithParameters
    :(ULong)periodExponent
    :(ULong)seed
    :(ULong)a
    :(ULong)b
{
    NSString * parameters = [ NSString stringWithFormat: @"dicg(%ul,%ul,%ul,%ul)", periodExponent, a, b, seed ];

    NPRandomNumberGenerator * generator = [[ NPRandomNumberGenerator alloc ] initWithName:@"dicg" parent:self parameters:parameters ];
	[ generators addObject:generator ];

    return [ generator autorelease ];
}

- (NPRandomNumberGenerator *) qcgGenerator
{
    return nil;
}

- (NPRandomNumberGenerator *) qcgGeneratorWithParameters
    :(ULong)periodLength
    :(ULong)seed
    :(ULong)a
    :(ULong)b
    :(ULong)c
{
    NSString * parameters = [ NSString stringWithFormat: @"qcg(%ul,%ul,%ul,%ul,%ul)", periodLength, a, b, c, seed ];

     NPRandomNumberGenerator * generator = [[ NPRandomNumberGenerator alloc ] initWithName:@"qcg" parent:self parameters:parameters ];
	[ generators addObject:generator ];

    return [ generator autorelease ];
}

@end
