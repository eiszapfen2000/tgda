#import <Foundation/Foundation.h>

#include "Basics/Types.h"

#import "NPPRandomNumberGeneration.h"


/*! \def */
#define NP_RNG_TT800	@"tt800"
#define NP_RNG_CTG		@"ctg"
#define NP_RNG_MRG		@"mrg"
#define NP_RNG_CMRG		@"cmrg"
#define NP_RNG_MT19937	@"mt19937"

#define NP_RNG_DEFAULT	NP_RNG_TT800

/*! \class NPRandomNumberGenerator
	\brief prng wrapper

	RandomGenerator class which encapsulates prng's functionality

*/

@interface NPRandomNumberGenerator : NSObject < NPPUniformFPRandomNumber, NPPUniformIntegerRandomNumber,
												NPPRandomNumberOptionals >
{
    struct prng * randomNumberGenerator;
}

//! Init with a default fixed parameter generator, TT800
- init;

//! Init with a prng_new compatible string
- initWithName
	: (NSString *) name
	;

- (void) dealloc;

- (NSString *) description;

@end
