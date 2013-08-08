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
#import "Graphics/Buffer/NPBufferObject.h"
#import "Graphics/Effect/NPEffect.h"
#import "Graphics/Effect/NPEffectTechnique.h"
#import "Graphics/Effect/NPEffectVariableFloat.h"
#import "Graphics/Geometry/NPFullscreenQuad.h"
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

@interface ODIWave (Private)

- (BOOL) generateTextureBuffer:(NSError **)error;
- (BOOL) generateRenderTargets:(NSError **)error;
- (void) clearRenderTargets;

@end

@implementation ODIWave (Private)

- (BOOL) generateTextureBuffer:(NSError **)error
{
    const int32_t kernelSize = 2 * kernelRadius + 1;

    NSData * kernelData
        = [ NSData dataWithBytesNoCopy:kernel
                                length:sizeof(float) * kernelSize * kernelSize
                          freeWhenDone:NO ];

    BOOL result
        = [ kernelBuffer
               generate:NpBufferObjectTypeTexture
             updateRate:NpBufferDataUpdateOnceUseOften
              dataUsage:NpBufferDataWriteCPUToGPU
             dataFormat:NpBufferDataFormatFloat32
             components:1
                   data:kernelData
             dataLength:[ kernelData length ]
                  error:error ];

    if ( result == YES )
    {
        [ kernelTexture attachBuffer:kernelBuffer
                    numberOfElements:kernelSize * kernelSize
                         pixelFormat:NpTexturePixelFormatR
                          dataFormat:NpTextureDataFormatFloat32 ];
    }

    return result;
}

- (BOOL) generateRenderTargets:(NSError **)error
{
    BOOL result
        = [ heightsTarget generate:NpRenderTargetColor
                             width:resolution.x
                            height:resolution.y
                       pixelFormat:NpTexturePixelFormatR
                        dataFormat:NpTextureDataFormatFloat32
                     mipmapStorage:NO
                             error:error ];

    result
        = result && [ prevHeightsTarget generate:NpRenderTargetColor
                                           width:resolution.x
                                          height:resolution.y
                                     pixelFormat:NpTexturePixelFormatR
                                      dataFormat:NpTextureDataFormatFloat32
                                   mipmapStorage:NO
                                           error:error ];

    result
        = result && [ depthDerivativeTarget generate:NpRenderTargetColor
                                               width:resolution.x
                                              height:resolution.y
                                         pixelFormat:NpTexturePixelFormatR
                                          dataFormat:NpTextureDataFormatFloat32
                                       mipmapStorage:NO
                                               error:error ];

    result
        = result && [ derivativeTarget generate:NpRenderTargetColor
                                          width:resolution.x
                                         height:resolution.y
                                    pixelFormat:NpTexturePixelFormatR
                                     dataFormat:NpTextureDataFormatFloat32
                                  mipmapStorage:NO
                                          error:error ];

    result
        = result && [ tempTarget generate:NpRenderTargetColor
                                    width:resolution.x
                                   height:resolution.y
                              pixelFormat:NpTexturePixelFormatR
                               dataFormat:NpTextureDataFormatFloat32
                            mipmapStorage:NO
                                    error:error ];

    return result;
}

- (void) clearRenderTargets
{
    [ rtc bindFBO ];

    [ heightsTarget
        attachToRenderTargetConfiguration:rtc
                         colorBufferIndex:0
                                  bindFBO:NO ];

    [ prevHeightsTarget
        attachToRenderTargetConfiguration:rtc
                         colorBufferIndex:1
                                  bindFBO:NO ];

    [ derivativeTarget
        attachToRenderTargetConfiguration:rtc
                         colorBufferIndex:2
                                  bindFBO:NO ];

    [ depthDerivativeTarget
        attachToRenderTargetConfiguration:rtc
                         colorBufferIndex:3
                                  bindFBO:NO ];

    [ tempTarget
        attachToRenderTargetConfiguration:rtc
                         colorBufferIndex:4
                                  bindFBO:NO ];

    [ rtc activateDrawBuffers ];
    [ rtc activateViewport ];

    [[ NPEngineGraphics instance ] clearFrameBuffer:YES depthBuffer:NO stencilBuffer:NO ];

    [ tempTarget            detach:NO ];
    [ depthDerivativeTarget detach:NO ];
    [ derivativeTarget      detach:NO ];
    [ prevHeightsTarget     detach:NO ];
    [ heightsTarget         detach:NO ];

    [ rtc deactivate ];
}

@end

static const IVector2 defaultResolution   = {.x = 256, .y = 256};
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

    kernelBuffer  = [[ NPBufferObject alloc ]  initWithName:@"Kernel BO" ];
    kernelTexture = [[ NPTextureBuffer alloc ] initWithName:@"Kernel TB" ];

    sourceTexture      = [[ NPTexture2D alloc ] initWithName:@"Source" ];
    obstructionTexture = [[ NPTexture2D alloc ] initWithName:@"Obstruction" ];
    depthTexture       = [[ NPTexture2D alloc ] initWithName:@"Depth" ];

    heightsTarget         = [[ NPRenderTexture alloc ] initWithName:@"Height Target"           ];
    prevHeightsTarget     = [[ NPRenderTexture alloc ] initWithName:@"Prev Height Target"      ];
    depthDerivativeTarget = [[ NPRenderTexture alloc ] initWithName:@"Depth Derivative Target" ];
    derivativeTarget      = [[ NPRenderTexture alloc ] initWithName:@"Derivative Target"       ];
    tempTarget            = [[ NPRenderTexture alloc ] initWithName:@"Temp Target"             ];

    rtc = [[ NPRenderTargetConfiguration alloc ] initWithName:@"RTC" ];

    fullscreenQuad = [[ NPFullscreenQuad alloc ] initWithName:@"iWave FSQ" ];

    return self;
}

- (void) dealloc
{
    SAFE_DESTROY(fullscreenQuad);
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

        NSAssert([ self generateTextureBuffer:NULL ] == YES, @"");

        lastKernelRadius = kernelRadius;
    }

    if ( resolution.x != lastResolution.x
         || resolution.y != lastResolution.y )
    {
        SAFE_FREE(source);
        SAFE_FREE(obstruction);
        SAFE_FREE(depth);

        const int32_t size = resolution.x * resolution.y;
        source      = ALLOC_ARRAY(float, size);
        obstruction = ALLOC_ARRAY(float, size);
        depth       = ALLOC_ARRAY(float, size);

        [ rtc setWidth:resolution.x  ];
        [ rtc setHeight:resolution.y ];
        
        NSAssert([ self generateRenderTargets:NULL ] == YES, @"");

        [ self clearRenderTargets ];

        lastResolution = resolution;
    }
}

- (void) render
{
}

@end

