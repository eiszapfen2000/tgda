#import "Basics/Types.h"

@protocol NPPUniformFPRandomNumber

- (Double) nextUniformFPRandomNumber;

@end

@protocol NPPUniformIntegerRandomNumber

- (ULong) nextUniformIntegerRandomNumber;

@end

@protocol NPPRandomNumberOptionals

- (void) reset;

- (void) reseed
	: (ULong) seed
	;

@end
