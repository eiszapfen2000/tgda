#import "NP.h"

@implementation NP

+ (id) Core
{
    return [ NPEngineCore instance ];
}

+ (id) Graphics
{
    return [ NPEngineGraphics instance ];
}

@end
