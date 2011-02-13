#import "NP.h"

@implementation NP

+ (NPLog *) Log
{
    return [ NPLog instance ];
}

+ (NPEngineCore *) Core
{
    return [ NPEngineCore instance ];
}

+ (NPEngineGraphics *) Graphics
{
    return [ NPEngineGraphics instance ];
}

+ (NPEngineSound *) Sound
{
    return [ NPEngineSound instance ];
}

@end
