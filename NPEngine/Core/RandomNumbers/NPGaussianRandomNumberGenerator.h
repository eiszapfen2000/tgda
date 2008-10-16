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

- (NPRandomNumberGenerator *)firstGenerator;
- (void) setFirstGenerator:(NPRandomNumberGenerator *)newFirstGenerator;
- (NPRandomNumberGenerator *)secondGenerator;
- (void) setSecondGenerator:(NPRandomNumberGenerator *)newSecondGenerator;

- (BOOL) ready;
- (void) checkForSubGenerators;

- (Double) nextGaussianFPRandomNumber;

- (NSString *) description;

@end
