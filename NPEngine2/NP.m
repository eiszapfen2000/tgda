#import "NP.h"

@implementation NP

+ (id) Log
{
    return [ NPLog instance ];
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
