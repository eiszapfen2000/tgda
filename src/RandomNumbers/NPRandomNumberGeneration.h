#import <Foundation/Foundation.h>

#include "prng.h"

@interface NPRandomNumberGenerator : NSObject
{
    struct prng * randomNumberGenerator;
}

- init;

@end
