#import "NPEngineCore.h"
#import "Core/Basics/NpBasics.h"
#import "Core/Math/NpMath.h"
#import "Core/Log/NPLogger.h"
#import "Core/Timer/NPTimer.h"
#import "Core/File/NPPathManager.h"
#import "Graphics/RenderContext/NPOpenGLRenderContextManager.h"
#import "Graphics/Model/NPModelManager.h"
#import "Graphics/Image/NPImageManager.h"
#import "Graphics/Material/NPTextureManager.h"
#import "Graphics/Material/NPEffectManager.h"
#import "Graphics/Camera/NPCameraManager.h"


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

    renderContextManager = [ [ NPOpenGLRenderContextManager alloc ] initWithName:@"NPEngine Core RenderContext Manager" parent:self ];

    modelManager = [ [ NPModelManager alloc ] initWithName:@"NPEngine Model Manager" parent:self ];
    imageManager = [ [ NPImageManager alloc ] initWithName:@"NPEngine Image Manager" parent:self ];
    textureManager = [ [ NPTextureManager alloc ] initWithName:@"NPEngine Texture Manager" parent:self ];
    effectManager = [ [ NPEffectManager alloc ] initWithName:@"NPEngine Effect Manager" parent:self ];

    cameraManager = [ [ NPCameraManager alloc ] initWithName:@"NPEngine Camera Manager" parent:self ];

    ready = NO;

    return self;
}

- (void) setup
{
    NPLOG(@"NPEngine Core setup....");

    [ pathManager setup ];
    [ imageManager setup ];
    [ effectManager setup ];

    ready = YES;

    NPLOG(@"done");
}

- (BOOL)isReady
{
    return ready;
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

- (NPOpenGLRenderContextManager *)renderContextManager
{
    return renderContextManager;
}

- (NPModelManager *)modelManager
{
    return modelManager;
}

- (NPImageManager *)imageManager
{
    return imageManager;
}

- (NPTextureManager *)textureManager
{
    return textureManager;
}

- (NPEffectManager *)effectManager
{
    return effectManager;
}

- (NPCameraManager *)cameraManager
{
    return cameraManager;
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
