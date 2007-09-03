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

- (void) dealloc;

@end
