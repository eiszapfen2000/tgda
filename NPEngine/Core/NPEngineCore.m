#import "NPEngineCore.h"
#import "Core/Basics/NpBasics.h"
#import "Core/Math/NpMath.h"
#import "Core/Log/NPLogger.h"
#import "Core/Timer/NPTimer.h"
#import "Core/File/NPPathManager.h"
#import "Graphics/Model/NPModelManager.h"
#import "Graphics/Material/NPEffectManager.h"
#import "Graphics/RenderContext/NPOpenGLRenderContextManager.h"

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
    npbasics_initialise();
    npmath_initialise();

    self = [ super initWithName:@"NPEngine Core" ];

    objectManager = [ [ NPObjectManager alloc ] initWithName:@"NPEngine Object Manager" parent:self ];
    logger = [ [ NPLogger alloc ] initWithName:@"NPEngine Logger" parent:self ];
    timer = [ [ NPTimer alloc ] initWithName:@"NPEngine Timer" parent:self ];
    pathManager = [ [ NPPathManager alloc ] initWithName:@"NPEngine Path Manager" parent:self ];

    modelManager = [ [ NPModelManager alloc ] initWithName:@"NPEngine Model Manager" parent:self ];
    //effectManager = [ [ NPEffectManager alloc ] initWithName:@"NPEngine Effect Manager" parent:self ];
    renderContextManager = [ [ NPOpenGLRenderContextManager alloc ] initWithName:@"NPEngine Core RenderContext Manager" parent:self ];

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

- (NPPathManager *)pathManager
{
    return pathManager;
}

- (NPModelManager *)modelManager
{
    return modelManager;
}

- (NPEffectManager *)effectManager
{
    return effectManager;
}

- (NPOpenGLRenderContextManager *)renderContextManager
{
    return renderContextManager;
}

- (void) setup
{
    [ pathManager setup ];   
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
