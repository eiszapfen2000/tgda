#define _GNU_SOURCE
#import <fenv.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSData.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSException.h>
#import <Foundation/NSFileManager.h>
#import <Foundation/NSLock.h>
#import <Foundation/NSPathUtilities.h>
#import <Foundation/NSPointerArray.h>
#import <Foundation/NSThread.h>
#import "Core/Container/NPAssetArray.h"
#import "Core/Container/NSPointerArray+NPEngine.h"
#import "Core/Thread/NPSemaphore.h"
#import "Core/Timer/NPTimer.h"
#import "Core/File/NSFileManager+NPEngine.h"
#import "Core/File/NPLocalPathManager.h"
#import "Core/World/NPTransformationState.h"
#import "Core/NPEngineCore.h"
#import "Graphics/Effect/NPEffect.h"
#import "Graphics/Effect/NPEffectTechnique.h"
#import "Graphics/Effect/NPEffectVariableFloat.h"
#import "Graphics/Texture/NPTexture2D.h"
#import "Graphics/Texture/NPTextureBindingState.h"
#import "Graphics/Texture/NPTextureBuffer.h"
#import "Graphics/RenderTarget/NPRenderTexture.h"
#import "Graphics/RenderTarget/NPRenderTargetConfiguration.h"
#import "Graphics/NPOrthographic.h"
#import "Graphics/NPEngineGraphics.h"
#import "ODIWave.h"

static const IVector2 defaultResolution = {.x = 256, .y = 256};
static const int32_t  defaultKernelRadius = 6;


@implementation ODIWave

- (id) init
{
    return [ self initWithName:@"ODIWave" ];
}

- (id) initWithName:(NSString *)newName
{
    self =  [ super initWithName:newName ];

    lastResolution.x = lastResolution.y = INT_MAX;
    resolution = defaultResolution;

    lastKernelRadius = INT_MAX;
    kernelRadius = defaultKernelRadius;

    return self;
}

- (void) dealloc
{
    SAFE_DESTROY(rtc);
    SAFE_DESTROY(tempTarget);
    SAFE_DESTROY(derivativeTarget);
    SAFE_DESTROY(depthDerivativeTarget);
    SAFE_DESTROY(prevHeightsTarget);
    SAFE_DESTROY(heightsTarget);

    SAFE_DESTROY(depthTexture);
    SAFE_DESTROY(obstructionTexture);
    SAFE_DESTROY(sourceTexture);
    SAFE_DESTROY(kernelTexture);
    SAFE_DESTROY(kernelBuffer);

    SAFE_FREE(depth);
    SAFE_FREE(obstruction);
    SAFE_FREE(source);
    SAFE_FREE(kernel);

    [ super dealloc ];
}

- (void) start
{
}

- (void) stop
{
}

- (void) update:(const double)frameTime
{
    if ( kernelRadius != lastKernelRadius )
    {
    }

    if ( resolution.x != lastResolution.x
         || resolution.y != lastResolution.y )
    {
    }
}

- (void) render
{
}

@end

