#import "Core/Math/NpMath.h"

#import "NPGaussianRandomNumberGenerator.h"
#import "NPRandomNumberGenerator.h"

@implementation NPGaussianRandomNumberGenerator

- init
{
    return [ self initWithName:@"NPEngine Gaussian Random Number Generator" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent
{
    return [ self initWithName:newName parent:newParent ];
}

- (id) initWithName:(NSString *)newName
             parent:(NPObject *)newParent
     firstGenerator:(NPRandomNumberGenerator *)newFirstGenerator
    secondGenerator:(NPRandomNumberGenerator *)newSecondGenerator
{
    self = [ super initWithName:newName parent:newParent ];

    [ firstGenerator retain ];
    [ secondGenerator retain ];

	useLastValue = NO;

    return self;
}

- (void) dealloc
{
	[ firstGenerator release ];
	[ secondGenerator release ];

	[ super dealloc ];
}

- (NSString *) description
{
	return [ [ firstGenerator description ] stringByAppendingString: [ secondGenerator description ] ];
}

- (Double) nextGaussianFPRandomNumber
{
	Double x1, x2, w;

	if ( useLastValue )
	{
		firstValue = secondValue;
		useLastValue = NO;
	}
	else
	{
		do
		{
			x1 = 2.0 * [ firstGenerator nextUniformFPRandomNumber ] - 1.0;
			x2 = 2.0 * [ secondGenerator nextUniformFPRandomNumber ] - 1.0;
			w = x1 * x1 + x2 * x2;
		}
		while ( w >= 1.0 || w == 0.0 );

		w = sqrt( (-2.0 * log( w ) ) / w );

		firstValue = x1 * w;
		secondValue = x2 * w;

		useLastValue = YES; 
	}

	return firstValue;
}

@end
