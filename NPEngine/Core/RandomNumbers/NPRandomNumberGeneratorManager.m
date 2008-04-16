#import "NPRandomNumberGeneratorManager.h"
#import "NPRandomNumberGenerator.h"
#import "NPGaussianRandomNumberGenerator.h"

@implementation NPRandomNumberGeneratorManager

- init
{
    return [ self initWithName:@"NPEngine  Random Number Generator Manager" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    self = [ super initWithName:newName parent:newParent ];

	fixedParameterGeneratorNames = [[ NSSet alloc ] initWithObjects: NP_RNG_TT800, NP_RNG_CTG, NP_RNG_MRG, NP_RNG_CMRG, nil ];
	generators = [ [ NSMutableArray alloc ] init ];

    return self;
}

- (void) dealloc
{
	[ generators release ];
    [ fixedParameterGeneratorNames release ];

	[ super dealloc ];
}

- (NPGaussianRandomNumberGenerator *) gaussianGenerator
{
    NPGaussianRandomNumberGenerator * generator = [[ NPGaussianRandomNumberGenerator alloc ] initWithName:@"" parent:self ];
	[ generators addObject: generator ];
	[ generator release ];
    
    return generator;
}

- (NPGaussianRandomNumberGenerator *) gaussianGeneratorWithFirstGenerator:(NPRandomNumberGenerator *)firstGenerator
                                                       andSecondGenerator:(NPRandomNumberGenerator *)secondGenerator
{
    NPGaussianRandomNumberGenerator * generator = [[ NPGaussianRandomNumberGenerator alloc ] initWithName:@"" 
                                                                                                   parent:self
                                                                                           firstGenerator:firstGenerator
                                                                                          secondGenerator:secondGenerator ];
	[ generators addObject: generator ];
	[ generator release ];
    
    return generator;
}


- (NPRandomNumberGenerator *) fixedParameterGeneratorWithRNGName:(NSString *)rngName;
{
	NPRandomNumberGenerator * generator = nil;

	if ( [ fixedParameterGeneratorNames containsObject:rngName ] )
	{
		generator = [[ NPRandomNumberGenerator alloc ] initWithName:@"" parent:self parameters:rngName ];
		[ generators addObject: generator ];
		[ generator release ];
	}
    else
    {
        NSLog(@"Wrong rng name, returning nil");
    }

	return generator;
}

- (NPRandomNumberGenerator *) mersenneTwisterWithSeed:(ULong)seed
{
    NSString * parameters = [[ NSString alloc ] initWithFormat: @"mt19937(%ul)", seed ];

    NPRandomNumberGenerator * generator = [[ NPRandomNumberGenerator alloc ] initWithName:@"" parent:self parameters:parameters ];
	[ generators addObject: generator ];
	[ generator release ];
    [ parameters release ];

    return generator;
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
    NSString * parameters = [[ NSString alloc ] initWithFormat: @"lcg(%ul,%ul,%ul,%ul)", periodLength, a, b, seed ];

    NPRandomNumberGenerator * generator = [[ NPRandomNumberGenerator alloc ] initWithName:@"" parent:self parameters:parameters ];
	[ generators addObject: generator ];
	[ generator release ];
    [ parameters release ];

    return generator;
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
    NSString * parameters = [[ NSString alloc ] initWithFormat: @"icg(%ul,%ul,%ul,%ul)", periodLength, a, b, seed ];

    NPRandomNumberGenerator * generator = [[ NPRandomNumberGenerator alloc ] initWithName:@"" parent:self parameters:parameters ];
	[ generators addObject: generator ];
	[ generator release ];
    [ parameters release ];

    return generator;
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
    NSString * parameters = [[ NSString alloc ] initWithFormat: @"eicg(%ul,%ul,%ul,%ul)", periodLength, a, b, seed ];

    NPRandomNumberGenerator * generator = [[ NPRandomNumberGenerator alloc ] initWithName:@"" parent:self parameters:parameters ];
	[ generators addObject: generator ];
	[ generator release ];
    [ parameters release ];

    return generator;
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
    NSString * parameters = [ [ NSString alloc ] initWithFormat: @"meicg(%ul,%ul,%ul,%ul)", periodLength, a, b, seed ];

    NPRandomNumberGenerator * generator = [[ NPRandomNumberGenerator alloc ] initWithName:@"" parent:self parameters:parameters ];
	[ generators addObject: generator ];
	[ generator release ];
    [ parameters release ];

    return generator;
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
    NSString * parameters = [ [ NSString alloc ] initWithFormat: @"dicg(%ul,%ul,%ul,%ul)", periodExponent, a, b, seed ];

    NPRandomNumberGenerator * generator = [[ NPRandomNumberGenerator alloc ] initWithName:@"" parent:self parameters:parameters ];
	[ generators addObject: generator ];
	[ generator release ];
    [ parameters release ];

    return generator;
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
    NSString * parameters = [ [ NSString alloc ] initWithFormat: @"qcg(%ul,%ul,%ul,%ul,%ul)", periodLength, a, b, c, seed ];

     NPRandomNumberGenerator * generator = [[ NPRandomNumberGenerator alloc ] initWithName:@"" parent:self parameters:parameters ];
	[ generators addObject: generator ];
	[ generator release ];
    [ parameters release ];

    return generator;
}

@end
