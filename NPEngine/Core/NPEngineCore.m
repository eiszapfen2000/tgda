#import "NPEngineCore.h"

static NPEngineCore * NP_ENGINE_CORE = nil;

@implementation NPEngineCore

+ (NPEngineCore *)instance
{
    NSLock * lock = [ [ NSLock alloc ] init ];

    if ( [ lock tryLock ] )
    {
        if ( NP_ENGINE_CORE == nil )
        {
            [ [ self alloc ] init ]; // assignment not done here
        }

        [ lock unlock ];
    }

    [ lock release ];

    return NP_ENGINE_CORE;
} 

+ (id)allocWithZone:(NSZone *)zone
{
    NSLock * lock = [ [ NSLock alloc ] init ];

    if ( [ lock tryLock ] )
    {
        if (NP_ENGINE_CORE == nil)
        {
            NP_ENGINE_CORE = [ super allocWithZone:zone ];

            [ lock unlock ];
            [ lock release ];

            return NP_ENGINE_CORE;  // assignment and return on first allocation
        }
    }

    [ lock release ];

    return nil; //on subsequent allocation attempts return nil
}

- (id)init
{
    self = [ super initWithName:@"NPEngine Core" ];

    objectManager = [ [ NPObjectManager alloc ] initWithName:@"NPEngine Object Manager" parent:self ];
    logger = [ [ NPLogger alloc ] initWithName:@"NPEngine Logger" parent:self fileName:@"np.txt" ];
    timer = [ [ NPTimer alloc ] initWithName:@"NPEngine Timer" parent:self ];

    renderContextManager = [ [ NPOpenGLRenderContextManager alloc ] initWithName:@"NP Engine Core RenderContext Manager" parent:self ];

    return self;
}

- (NPLogger *)logger
{
    return logger;
}

- (NPTimer *)timer
{
    return timer;
}

- (NPObjectManager *)objectManager
{
    return objectManager;
}

- (NPOpenGLRenderContextManager *)renderContextManager
{
    return renderContextManager;
}

- (void) setupInitialState
{
    
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
