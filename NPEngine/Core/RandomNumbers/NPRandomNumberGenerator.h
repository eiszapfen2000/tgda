#import "Core/NPObject/NPObject.h"
#import "prng.h"

/*! \def */
#define NP_RNG_TT800	@"tt800"
#define NP_RNG_CTG		@"ctg"
#define NP_RNG_MRG		@"mrg"
#define NP_RNG_CMRG		@"cmrg"

#define NP_RNG_DEFAULT	NP_RNG_TT800

/*! \class NPRandomNumberGenerator
	\brief prng wrapper

	RandomGenerator class which encapsulates prng's functionality

*/

@interface NPRandomNumberGenerator : NPObject
{
    struct prng * randomNumberGenerator;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent parameters:(NSString *)rngParameters;
- (void) dealloc;

- (void) reset;

- (Double) nextUniformFPRandomNumber;
- (void) arrayOfUniformFPRandomNumbers:(Double *)array count:(UInt64)count;
- (ULong) nextUniformIntegerRandomNumber;
- (void) reseed:(ULong)seed;

- (NSString *) description;

@end
