#import "Core/Math/NpMath.h"

#import "NPGaussianRandomNumberGenerator.h"
#import "NPRandomNumberGenerator.h"

#import "NP.h"

@implementation NPGaussianRandomNumberGenerator

- init
{
    return [ self initWithName:@"NPEngine Gaussian Random Number Generator" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent
{
    return [ self initWithName:newName parent:newParent firstGenerator:nil secondGenerator:nil ];
}

- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject> )newParent
     firstGenerator:(NPRandomNumberGenerator *)newFirstGenerator
    secondGenerator:(NPRandomNumberGenerator *)newSecondGenerator
{
    self = [ super initWithName:newName parent:newParent ];

    if ( newFirstGenerator != nil )
    {
        firstGenerator = [ newFirstGenerator retain ];
    }

    if ( newSecondGenerator != nil )
    {
        secondGenerator = [ newSecondGenerator retain ];
    }

    [ self checkForSubGenerators ];

	useLastValue = NO;

    return self;
}

- (void) dealloc
{
	[ firstGenerator  release ];
	[ secondGenerator release ];

	[ super dealloc ];
}

- (NPRandomNumberGenerator *)firstGenerator
{
    return firstGenerator;
}

- (NPRandomNumberGenerator *)secondGenerator
{
    return secondGenerator;
}

- (void) setFirstGenerator:(NPRandomNumberGenerator *)newFirstGenerator
{
    ASSIGN(firstGenerator,newFirstGenerator);

    [ self checkForSubGenerators ];
}

- (void) setSecondGenerator:(NPRandomNumberGenerator *)newSecondGenerator
{
    ASSIGN(secondGenerator,newSecondGenerator);

    [ self checkForSubGenerators ];
}

- (BOOL) ready
{
    return ready;
}

- (void) checkForSubGenerators
{
    if ( firstGenerator != nil && secondGenerator != nil )
    {
        ready = YES;
    }
}

- (Double) nextGaussianFPRandomNumber
{
    return [ self nextGaussianFPRandomNumberWithMean:0.0 andVariance:1.0 ];
}

- (Double) nextGaussianFPRandomNumberWithMean:(Double)mean andVariance:(Double)variance
{
    if ( ready == YES )
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

	    return mean + firstValue * variance;
    }

    NPLOG_WARNING(@"Generator not ready, returning 0");
    return 0.0;
}

- (NSString *) description
{
	return [[ firstGenerator description ] stringByAppendingString: [ secondGenerator description ]];
}

@end
