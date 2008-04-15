#import "Core/NPObject/NPObject.h"

@class NPRandomNumberGenerator;

@interface NPGaussianRandomNumberGenerator : NPObject
{
	NPRandomNumberGenerator * firstGenerator;
    NPRandomNumberGenerator * secondGenerator;

	BOOL useLastValue;

	Double firstValue, secondValue;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName
             parent:(NPObject *)newParent
     firstGenerator:(NPRandomNumberGenerator *)newFirstGenerator
    secondGenerator:(NPRandomNumberGenerator *)newSecondGenerator
                   ;
- (void) dealloc;

- (Double) nextGaussianFPRandomNumber;

- (NSString *) description;

@end
