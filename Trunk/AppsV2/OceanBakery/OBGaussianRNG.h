#import "Core/NPObject/NPObject.h"

@class OBRNG;

@interface OBGaussianRNG : NPObject
{
	OBRNG * firstGenerator;
    OBRNG * secondGenerator;

    BOOL ready;
	BOOL useLastValue;

	double firstValue, secondValue;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName
     firstGenerator:(OBRNG *)newFirstGenerator
    secondGenerator:(OBRNG *)newSecondGenerator
                   ;
- (void) dealloc;

- (void) reset;

- (OBRNG *) firstGenerator;
- (OBRNG *) secondGenerator;
- (void) setFirstGenerator:(OBRNG *)newFirstGenerator;
- (void) setSecondGenerator:(OBRNG *)newSecondGenerator;

- (double) nextGaussianFPRandomNumber;
- (double) nextGaussianFPRandomNumberWithMean:(double)mean
                                     variance:(double)variance
                                             ;

- (NSString *) description;

@end
