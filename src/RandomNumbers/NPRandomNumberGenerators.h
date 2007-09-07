#import <Foundation/Foundation.h>

#import "Basics/Types.h"
#import "NPPRandomNumberGeneration.h"

#define NP_RNG_TT800	@"tt800"
#define NP_RNG_CTG		@"ctg"
#define NP_RNG_MRG		@"mrg"
#define NP_RNG_CMRG		@"cmrg"
#define NP_RNG_MT19937	@"mt19937"

#define NP_RNG_DEFAULT	NP_RNG_TT800

/*! \class NPRandomNumberGenerator
	\brief nix

	braaaaak

*/

@interface NPRandomNumberGenerator : NSObject < NPPUniformFPRandomNumber, NPPUniformIntegerRandomNumber,
												NPPRandomNumberOptionals >
{
    struct prng * randomNumberGenerator;
}

- init;

- initWithName
	: (NSString *) name
	;

- (void) dealloc;

@end
