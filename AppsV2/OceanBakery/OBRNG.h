#import "prng.h"
#import "Core/NPObject/NPObject.h"

/*! \def */
#define NP_RNG_TT800	@"tt800"
#define NP_RNG_CTG		@"ctg"
#define NP_RNG_MRG		@"mrg"
#define NP_RNG_CMRG		@"cmrg"
#define NP_RNG_MERSENNE @"mersenne"

#define NP_RNG_DEFAULT	NP_RNG_TT800

/*! \class NPRandomNumberGenerator
	\brief prng wrapper

	RandomGenerator class which encapsulates prng's functionality

*/

@interface OBRNG : NPObject
{
    struct prng * randomNumberGenerator;
}

- (id) init;
- (id) initWithName:(NSString *)newName;
- (id) initWithName:(NSString *)newName
                rng:(NSString *)rngName
                   ;
- (void) dealloc;

- (void) reset;

- (double) nextUniformFPRandomNumber;
- (NSUInteger) nextUniformIntegerRandomNumber;
- (void) arrayOfUniformFPRandomNumbers:(double *)array
                                 count:(int32_t)count
                                      ;

- (void) seed:(NSUInteger)seed;

- (NSString *) description;

@end
