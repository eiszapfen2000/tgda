#import <Foundation/Foundation.h>

#import "NPPRandomNumberGeneration.h"

@interface NPGaussianRandomNumberGenerator : NSObject < NPPUniformFPRandomNumber >
{
	NSObject < NPPUniformFPRandomNumber > * firstGenerator;
	NSObject < NPPUniformFPRandomNumber > * secondGenerator;

	BOOL useLastValue;

	Double firstValue, secondValue;
}

- init;

- initWithGenerators
	: ( NSObject < NPPUniformFPRandomNumber > *) firstGenerator
	: ( NSObject < NPPUniformFPRandomNumber > *) secondGenerator
	;

- (void) dealloc;

@end
