#import "NPEngineCore.h"
#import "Core/Basics/NpBasics.h"
#import "Core/Math/NpMath.h"
#import "Core/Log/NPLogger.h"
#import "Core/Timer/NPTimer.h"
#import "Core/File/NPPathManager.h"
#import "Core/RandomNumbers/NPRandomNumberGeneratorManager.h"
#import "Core/World/NPTransformationStateManager.h"
#import "Graphics/RenderContext/NPOpenGLRenderContextManager.h"
#import "Graphics/State/NPStateConfiguration.h"
#import "Graphics/Model/NPModelManager.h"
#import "Graphics/Image/NPImageManager.h"
#import "Graphics/Material/NPTextureManager.h"
#import "Graphics/Material/NPEffectManager.h"
#import "Graphics/Camera/NPCameraManager.h"


static NPEngineCore * NP_ENGINE_CORE = nil;

@implementation NPEngineCore

+ (NPEngineCore *)instance
{
    NSLock * lock = [[ NSLock alloc ] init ];

    if ( [ lock tryLock ] )
    {
        if ( NP_ENGINE_CORE == nil )
        {
            [[ self alloc ] init ]; // assignment not done here
        }

        [ lock unlock ];
    }

    [ lock release ];

    return NP_ENGINE_CORE;
} 

+ (id)allocWithZone:(NSZone *)zone
{
    NSLock * lock = [[ NSLock alloc ] init ];

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

- (id) init
{
    return [ self initWithName:@"NPEngine Core" parent:nil ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject> )newParent;
{
    npbasics_initialise();
    npmath_initialise();

    self = [ super init ];

    name = [ newName retain ];
    objectID = crc32_of_pointer(self);

    objectManager = [[ NPObjectManager alloc ] init ];
    logger        = [[ NPLogger        alloc ] initWithName:@"NPEngine Logger"       parent:self ];
    timer         = [[ NPTimer         alloc ] initWithName:@"NPEngine Timer"        parent:self ];
    pathManager   = [[ NPPathManager   alloc ] initWithName:@"NPEngine Path Manager" parent:self ];

    randomNumberGeneratorManager = [[ NPRandomNumberGeneratorManager alloc ] initWithName:@"NPEngine RandomNumberGenerator Manager" parent:self ];
    transformationStateManager   = [[ NPTransformationStateManager   alloc ] initWithName:@"NPEngine Transformation State Manager"  parent:self ];

    renderContextManager = [[ NPOpenGLRenderContextManager alloc ] initWithName:@"NPEngine RenderContext Manager" parent:self ];

    modelManager   = [[ NPModelManager   alloc ] initWithName:@"NPEngine Model Manager"   parent:self ];
    imageManager   = [[ NPImageManager   alloc ] initWithName:@"NPEngine Image Manager"   parent:self ];
    textureManager = [[ NPTextureManager alloc ] initWithName:@"NPEngine Texture Manager" parent:self ];
    effectManager = [[ NPEffectManager   alloc ] initWithName:@"NPEngine Effect Manager"  parent:self ];

    stateConfiguration         = [[ NPStateConfiguration         alloc ] initWithName:@"NPEngine GPU States"              parent:self ];
    textureBindingStateManager = [[ NPTextureBindingStateManager alloc ] initWithName:@"NPEngine Texture Binding Manager" parent:self ];

    cameraManager = [[ NPCameraManager alloc ] initWithName:@"NPEngine Camera Manager" parent:self ];

    ready = NO;

    return self;
}

- (void) dealloc
{
    NPLOG(@"Dealloc");

    [ cameraManager release ];
    [ modelManager release ];
    [ textureBindingStateManager release ];
    [ textureManager release ];
    [ imageManager release ];
    [ effectManager release ];
    [ stateConfiguration release ];
    [ renderContextManager release ];
    [ transformationStateManager release ];
    [ randomNumberGeneratorManager release ];
    [ pathManager release ];
    [ timer release ];
    [ logger release ];
    [ objectManager release ];

    [ name release ];

    [ super dealloc ];
}

- (void) setup
{
    NPLOG(@"NPEngine Core setup....");

    NPLOG(@"Checking for Rendercontext...");

    UInt rcCount = [[ renderContextManager renderContexts ] count ];
    if ( rcCount == 0 )
    {
        NPLOG_ERROR(@"No RenderContext found, bailing out");
        return;
    }
    else
    {
        NPLOG(@"Rendercontext available");
    }

    [ pathManager setup ];
    [ transformationStateManager setup ];

    [ imageManager   setup ];
    [ textureManager setup ];
    [ effectManager  setup ];

    [ textureBindingStateManager setup ];

    [ cameraManager setup ];

    [ stateConfiguration activate ];

    ready = YES;

    NPLOG(@"NPEngine Core ready");
    NPLOG(@"");
}

- (NSString *) name
{
    return name;
}

- (void) setName:(NSString *)newName
{
    if ( name != newName )
    {
        [ name release ];

        name = [ newName retain ];
    }
}

- (NPObject *) parent
{
    return nil;
}

- (void) setParent:(NPObject *)newParent
{
}

- (UInt32) objectID
{
    return objectID;
}

- (BOOL) ready
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

- (NPRandomNumberGeneratorManager *) randomNumberGeneratorManager
{
    return randomNumberGeneratorManager;
}

- (NPTransformationStateManager *)transformationStateManager
{
    return transformationStateManager;
}

- (NPOpenGLRenderContextManager *)renderContextManager
{
    return renderContextManager;
}

- (NPStateConfiguration *) stateConfiguration
{
    return stateConfiguration;
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

- (NPTextureBindingStateManager *)textureBindingStateManager
{
    return textureBindingStateManager;
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
