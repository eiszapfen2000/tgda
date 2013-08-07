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

static double G_zero(double sigma, int32_t n, double deltaQ)
{
    double result = 0.0;

    for (int32_t i = 0; i < n; i++)
    {
        double di = (double)i;
        double qn = di * deltaQ;
        double qnSquare = qn * qn;

        result += qnSquare * exp(-1.0 * sigma * qnSquare);        
    }

    return result;
}

static void G(int32_t P, double sigma, int32_t n, double deltaQ, float ** kernel)
{
    assert(kernel != NULL);

    const int32_t kernelSize = 2 * P + 1;
    const double gZero = G_zero(sigma, n, deltaQ);

    *kernel = ALLOC_ARRAY(float, kernelSize * kernelSize);

    /*
        Memory layout

        6 7 8
        3 4 5
        0 1 2
    */

    for (int32_t l = -P; l < P + 1; l++)
    {
        for (int32_t k = -P; k < P + 1; k++)
        {
            const double dl = (double)l;
            const double dk = (double)k;
            const double r = sqrt(dk * dk + dl * dl);

            double element = 0.0;

            for (int32_t i = 0; i < n; i++)
            {
                double di = (double)i;
                double qn = di * deltaQ;
                double qnSquare = qn * qn;

                element += qnSquare * exp(-1.0 * sigma * qnSquare) * j0(r * qn);
            }

            const int32_t indexk = k + P;
            const int32_t indexl = l + P;
            const int32_t index = indexl * kernelSize + indexk;

            (*kernel)[index] = (float)(element / gZero);
        }
    }
}

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
        SAFE_FREE(kernel);
        G(kernelRadius, 1.0, 10000, 0.001, &kernel);

        lastKernelRadius = kernelRadius;
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

