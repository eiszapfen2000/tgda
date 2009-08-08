#import "Core/NPObject/NPObject.h"

@class NPRandomNumberGenerator;

@interface NPGaussianRandomNumberGenerator : NPObject
{
	NPRandomNumberGenerator * firstGenerator;
    NPRandomNumberGenerator * secondGenerator;

    BOOL ready;
	BOOL useLastValue;

	Double firstValue, secondValue;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (id) initWithName:(NSString *)newName
             parent:(id <NPPObject> )newParent
     firstGenerator:(NPRandomNumberGenerator *)newFirstGenerator
    secondGenerator:(NPRandomNumberGenerator *)newSecondGenerator
                   ;
- (void) dealloc;

- (NPRandomNumberGenerator *) firstGenerator;
- (NPRandomNumberGenerator *) secondGenerator;
- (void) setFirstGenerator:(NPRandomNumberGenerator *)newFirstGenerator;
- (void) setSecondGenerator:(NPRandomNumberGenerator *)newSecondGenerator;

- (void) reset;

- (BOOL) ready;
- (void) checkForSubGenerators;

- (Double) nextGaussianFPRandomNumber;
- (Double) nextGaussianFPRandomNumberWithMean:(Double)mean andVariance:(Double)variance;

- (NSString *) description;

@end
