#import "NPRandomNumberGeneration.h"

@implementation NPRandomNumberGenerator

- init
{
    self = [ super init ];

    randomNumberGenerator = prng_new("external(tt800)");

    if( randomNumberGenerator == NULL )
    {
        NSLog(@"brak");
    }

    return self;
}

@end
