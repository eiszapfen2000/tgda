#import "Core/NPObject/NPObject.h"

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
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent;
- (id) initWithName:(NSString *)newName parent:(NPObject *)newParent parameters:(NSString *)rngParameters;
- (void) dealloc;

- (Double) nextUniformFPRandomNumber;
- (void) arrayOfUniformFPRandomNumbers:(Double *)array count:(UInt64)count;
- (ULong) nextUniformIntegerRandomNumber;
- (void) reseed:(ULong)seed;
- (void) reset;

- (NSString *) description;

@end
