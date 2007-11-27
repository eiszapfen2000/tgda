#import "NPEngineCore.h"

static NPEngineCore * NP_ENGINE_CORE = nil;

@implementation NPEngineCore

+ (NPEngineCore *)instance
{
    @synchronized(self)
    {
        if ( NP_ENGINE_CORE == nil )
        {
            [ [ self alloc ] init ]; // assignment not done here
        }
    }

    return NP_ENGINE_CORE;
} 

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (NP_ENGINE_CORE == nil)
        {
            NP_ENGINE_CORE = [ super allocWithZone:zone ];

            return NP_ENGINE_CORE;  // assignment and return on first allocation
        }
    }

    return nil; //on subsequent allocation attempts return nil

}

- (id)init
{
    self = [ super initWithName:@"NPEngine Core" ];

    logger = [ [ NPLogger alloc ] initWithName:@"NPEngine Logger" parent:self fileName:@"np.txt" ];
    timer = [ [ NPTimer alloc ] initWithName:@"NPEngine Timer" parent:self ];

    return self;

}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (unsigned)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released
} 

- (void)release
{
    //do nothing
} 

- (id)autorelease
{
    return self;
}

@end
