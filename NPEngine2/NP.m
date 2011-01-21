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

+ (id) Graphics
{
    return [ NPEngineGraphics instance ];
}

+ (id) Sound
{
    return [ NPEngineSound instance ];
}

@end
