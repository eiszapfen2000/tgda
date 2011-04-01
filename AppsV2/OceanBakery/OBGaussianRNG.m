#import "Core/Math/NpMath.h"
#import "OBRNG.h"
#import "OBGaussianRNG.h"

@interface OBGaussianRNG (Private)

- (void) checkForSubGenerators;

@end

@implementation OBGaussianRNG (Private)

- (void) checkForSubGenerators
{
    if ( firstGenerator != nil && secondGenerator != nil )
    {
        ready = YES;
    }
}

@end

@implementation OBGaussianRNG

- init
{
    return [ self initWithName:@"Gaussian RNG" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName
                firstGenerator:nil
               secondGenerator:nil ];
}

- (id) initWithName:(NSString *)newName
     firstGenerator:(OBRNG *)newFirstGenerator
    secondGenerator:(OBRNG *)newSecondGenerator
{
    self = [ super initWithName:newName ];

    if ( newFirstGenerator != nil )
    {
        firstGenerator = RETAIN(newFirstGenerator);
    }

    if ( newSecondGenerator != nil )
    {
        secondGenerator = RETAIN(newSecondGenerator);
    }

    [ self checkForSubGenerators ];

	useLastValue = NO;

    return self;
}

- (void) dealloc
{
	SAFE_DESTROY(firstGenerator);
    SAFE_DESTROY(secondGenerator);

	[ super dealloc ];
}

- (void) reset
{
    if ( firstGenerator != nil )
    {
        [ firstGenerator  reset ];

    }

    if ( secondGenerator != nil )
    {
        [ secondGenerator reset ];
    }
}

- (BOOL) ready
{
    return ready;
}

- (OBRNG *)firstGenerator
{
    return firstGenerator;
}

- (OBRNG *)secondGenerator
{
    return secondGenerator;
}

- (void) setFirstGenerator:(OBRNG *)newFirstGenerator
{
    ASSIGN(firstGenerator, newFirstGenerator);

    [ self checkForSubGenerators ];
}

- (void) setSecondGenerator:(OBRNG *)newSecondGenerator
{
    ASSIGN(secondGenerator, newSecondGenerator);

    [ self checkForSubGenerators ];
}

- (double) nextGaussianFPRandomNumber
{
    return [ self nextGaussianFPRandomNumberWithMean:0.0
                                            variance:1.0 ];
}

- (double) nextGaussianFPRandomNumberWithMean:(double)mean
                                     variance:(double)variance
{
    if ( ready == YES )
    {
	    double x1, x2, w;

	    if ( useLastValue )
	    {
		    firstValue = secondValue;
		    useLastValue = NO;
	    }
	    else
	    {
		    do
		    {
			    x1 = 2.0 * [ firstGenerator  nextUniformFPRandomNumber ] - 1.0;
			    x2 = 2.0 * [ secondGenerator nextUniformFPRandomNumber ] - 1.0;
			    w = x1 * x1 + x2 * x2;
		    }
		    while ( w >= 1.0 || w == 0.0 );

		    w = sqrt( (-2.0 * log( w ) ) / w );

		    firstValue = x1 * w;
		    secondValue = x2 * w;

		    useLastValue = YES; 
	    }

	    return mean + firstValue * variance;
    }

    NSLog(@"Generator not ready, returning 0");
    return 0.0;
}

- (NSString *) description
{
	return [[ firstGenerator description ] stringByAppendingString: [ secondGenerator description ]];
}

@end
