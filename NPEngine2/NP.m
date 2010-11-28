#import "NP.h"

@implementation NP

+ (id) Logger
{
    return [ NPLogger instance ];
}

+ (id) Core
{
    return [ NPEngineCore instance ];
}

+ (id) Sound
{
    return [ NPEngineSound instance ];
}

@end
