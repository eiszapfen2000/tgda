#include <math.h>

#import "NPGaussianRandomNumberGenerator.h"
#import "NPRandomNumberGenerators.h"

#import "Math/Utilities.h"

@implementation NPGaussianRandomNumberGenerator

- init
{
	self = [ super init ];

	firstGenerator = [ [ NPRandomNumberGenerator alloc ] init ];
	secondGenerator = [ [ NPRandomNumberGenerator alloc ] init ];

	useLastValue = NO;

	return self;
}

- initWithGenerators
	: ( NSObject < NPPUniformFPRandomNumber > *) newFirstGenerator
	: ( NSObject < NPPUniformFPRandomNumber > *) newSecondGenerator
{
	self = [ super init ];

	firstGenerator = [ newFirstGenerator retain ];
	secondGenerator = [ newSecondGenerator retain ];

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
