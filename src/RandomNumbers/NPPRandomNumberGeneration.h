#include "Basics/Types.h"

@protocol NPPUniformFPRandomNumber

- (Double) nextUniformFPRandomNumber;

- (void) arrayOfUniformFPRandomNumbers
    : (Double *) array
    : (UInt64) count
    ;

@end

@protocol NPPUniformIntegerRandomNumber

- (ULong) nextUniformIntegerRandomNumber;

@end

@protocol NPPGaussianFPRandomNumber

- (Double) nextGaussianFPRandomNumber;

@end

@protocol NPPRandomNumberOptionals

- (void) reset;

- (void) reseed
	: (ULong) seed
	;

@end
