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
#import "Graphics/Effect/NPEffectVariableInt.h"
#import "Graphics/Geometry/NPFullscreenQuad.h"
#import "Graphics/Geometry/NPVertexArray.h"
#import "Graphics/Texture/NPTexture2D.h"
#import "Graphics/Texture/NPTextureBindingState.h"
#import "Graphics/Texture/NPTextureBuffer.h"
#import "Graphics/RenderTarget/NPRenderTexture.h"
#import "Graphics/RenderTarget/NPRenderTargetConfiguration.h"
#import "Graphics/NPOrthographic.h"
#import "Graphics/NPEngineGraphics.h"
#import "NP.h"
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
- (BOOL) generateMesh:(NSError **)error;
- (void) clearRenderTargets;
- (void) uploadInputData;

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

- (BOOL) generateMesh:(NSError **)error
{
    NSAssert(resolution.x > 0 && resolution.y > 0, @"");

    const uint32_t numberOfVertices = resolution.x * resolution.y;
    const uint32_t numberOfTriangles = (resolution.x - 1) * (resolution.y - 1) * 2;
    const uint32_t numberOfIndices = numberOfTriangles * 3;

    FVector2 * vertices = ALLOC_ARRAY(FVector2, numberOfVertices);
    uint32_t * indices  = ALLOC_ARRAY(uint32_t, numberOfIndices);

    for ( int32_t i = 0; i < resolution.y; i++ )
    {
        for ( int32_t j = 0; j < resolution.x; j++ )
        {
            vertices[i*resolution.x + j] = (FVector2){.x = j, .y = i};
        }
    }

    int32_t index = 0;

    for ( int32_t i = 0; i < resolution.y - 1; i++ )
    {
        for ( int32_t j = 0; j < resolution.x - 1; j++ )
        {
            indices[index++] = (i*resolution.x) + j;
            indices[index++] = ((i+1)*resolution.x) + j;
            indices[index++] = ((i+1)*resolution.x) + j + 1;

            indices[index++] = ((i+1)*resolution.x) + j + 1;
            indices[index++] = (i*resolution.x) + j + 1;
            indices[index++] = (i*resolution.x) + j;
        }
    }

    NSData * xzData
        = [ NSData dataWithBytesNoCopy:vertices
                                length:numberOfVertices * sizeof(FVector2)
                          freeWhenDone:NO ];

    NSData * emptyData = [ NSData data ];

    NSData * indexData
        = [ NSData dataWithBytesNoCopy:indices
                                length:numberOfIndices * sizeof(uint32_t)
                          freeWhenDone:NO ];

    BOOL success
        = [ xzStream generate:NpBufferObjectTypeGeometry
                   updateRate:NpBufferDataUpdateOnceUseOften
                    dataUsage:NpBufferDataWriteCPUToGPU
                   dataFormat:NpBufferDataFormatFloat32
                   components:2
                         data:xzData
                   dataLength:[xzData length]
                        error:error ];

    
    success
        = success && [ yStream generate:NpBufferObjectTypeGeometry
                             updateRate:NpBufferDataUpdateOnceUseOften
                              dataUsage:NpBufferDataWriteCPUToGPU
                             dataFormat:NpBufferDataFormatFloat32
                             components:1
                                   data:emptyData
                             dataLength:numberOfVertices * sizeof(float)
                                  error:error ];

    success
        = success && [ indexStream generate:NpBufferObjectTypeIndices
                                 updateRate:NpBufferDataUpdateOnceUseOften
                                  dataUsage:NpBufferDataWriteCPUToGPU
                                 dataFormat:NpBufferDataFormatUInt32
                                 components:1
                                       data:indexData
                                 dataLength:[indexData length]
                                      error:error ];

    success
        = success && [ mesh setVertexStream:xzStream
                                 atLocation:NpVertexStreamAttribute0
                                      error:error ];

    success
        = success && [ mesh setVertexStream:yStream
                                 atLocation:NpVertexStreamAttribute1
                                      error:error ];

    success
        = success && [ mesh setIndexStream:indexStream
                                     error:error ];
    
    FREE(vertices);
    FREE(indices);

    return success;
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

    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:NO stencilBuffer:NO ];

    [ tempTarget            detach:NO ];
    [ depthDerivativeTarget detach:NO ];
    [ derivativeTarget      detach:NO ];
    [ prevHeightsTarget     detach:NO ];
    [ heightsTarget         detach:NO ];

    [ rtc deactivate ];
}

- (void) uploadInputData
{
    const NSUInteger numberOfBytes
        = sizeof(float) * (NSUInteger)(resolution.x * resolution.y);

    NSData * sourceData
        = [ NSData dataWithBytesNoCopy:source
                                length:numberOfBytes
                          freeWhenDone:NO ];

    NSData * obstructionData
        = [ NSData dataWithBytesNoCopy:obstruction
                                length:numberOfBytes
                          freeWhenDone:NO ];

    /*
    NSData * depthData
        = [ NSData dataWithBytesNoCopy:depth
                                length:numberOfBytes
                          freeWhenDone:NO ];
    */


    [ sourceTexture generateUsingWidth:resolution.x
                                height:resolution.y
                           pixelFormat:NpTexturePixelFormatR
                            dataFormat:NpTextureDataFormatFloat32
                               mipmaps:NO
                                  data:sourceData ];

    [ obstructionTexture generateUsingWidth:resolution.x
                                     height:resolution.y
                                pixelFormat:NpTexturePixelFormatR
                                 dataFormat:NpTextureDataFormatFloat32
                                    mipmaps:NO
                                       data:obstructionData ];

    /*
    [ depthTexture generateUsingWidth:resolution.x
                               height:resolution.y
                          pixelFormat:NpTexturePixelFormatR
                           dataFormat:NpTextureDataFormatFloat32
                              mipmaps:NO
                                 data:depthData ];
    */
}

@end

static const IVector2 defaultResolution   = {.x = 256, .y = 256};
static const int32_t  defaultKernelRadius = 6;
static const double desiredDeltaTime = 1.0 / 60.0;

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

    alpha = 0.3f;
    accumulatedDeltaTime = 0.0;

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

    effect
        = [[[ NP Graphics ] effects ] getAssetWithFileName:@"iWave.effect" ];

    ASSERT_RETAIN(effect);

    addSourceObstructionT = [ effect techniqueWithName:@"height_plus_source_mul_obstruction" ];
    convolutionT = [ effect techniqueWithName:@"convolution" ];
    propagationT = [ effect techniqueWithName:@"propagation" ];

    ASSERT_RETAIN(addSourceObstructionT);
    ASSERT_RETAIN(convolutionT);
    ASSERT_RETAIN(propagationT);

    kernelRadiusV = [ effect variableWithName:@"kernelRadius" ];
    dtAlphaV      = [ effect variableWithName:@"dt_alpha"     ];

    ASSERT_RETAIN(kernelRadiusV);
    ASSERT_RETAIN(dtAlphaV);

    xzStream    = [[ NPBufferObject alloc ] initWithName:@"iWave XZ Stream" ];
    yStream     = [[ NPBufferObject alloc ] initWithName:@"iWave Y Stream"  ];
    indexStream = [[ NPBufferObject alloc ] initWithName:@"Indices" ];
    mesh = [[ NPVertexArray alloc ] initWithName:@"iWave Mesh" ];

    return self;
}

- (void) dealloc
{
    SAFE_DESTROY(mesh);
    SAFE_DESTROY(indexStream);
    SAFE_DESTROY(yStream);
    SAFE_DESTROY(xzStream);

    SAFE_DESTROY(dtAlphaV);
    SAFE_DESTROY(kernelRadiusV);
    SAFE_DESTROY(propagationT);
    SAFE_DESTROY(convolutionT);
    SAFE_DESTROY(addSourceObstructionT);
    SAFE_DESTROY(effect);
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

- (NPTexture2D *) sourceTexture
{
    return sourceTexture;
}

- (NPTexture2D *) obstructionTexture
{
    return obstructionTexture;
}

- (id < NPPTexture >) derivativeTexture
{
    return [ derivativeTarget texture ];
}

- (id < NPPTexture >) heightTexture
{
    return [ heightsTarget texture ];
}

- (id < NPPTexture >) prevHeightTexture
{
    return [ prevHeightsTarget texture ];
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

        const uint32_t size = (uint32_t)(resolution.x * resolution.y);
        source      = ALLOC_ARRAY(float, size);
        obstruction = ALLOC_ARRAY(float, size);
        depth       = ALLOC_ARRAY(float, size);

        memset(source, 0, sizeof(float) * size);

        for ( uint32_t i = 0; i < size; i++ )
        {
            obstruction[i] = 1.0f;
            depth[i] = 1.0f;
        }

        [ rtc setWidth:resolution.x  ];
        [ rtc setHeight:resolution.y ];
        
        NSAssert([ self generateRenderTargets:NULL ] == YES, @"");
        [ self clearRenderTargets ];
        NSAssert([ self generateMesh:NULL ] == YES, @"");

        lastResolution = resolution;
    }

    accumulatedDeltaTime += frameTime;
    if ( accumulatedDeltaTime < desiredDeltaTime )
    {
        return;
    }
    
    {
        int randomX = rand() % resolution.x;
        int randomY = rand() % resolution.y;

        source[randomY * resolution.x + randomX] = 0.5;
    }

    [ self uploadInputData ];

    [[[ NP Core ] transformationState ] reset ];
    [[[ NP Graphics ] textureBindingState ] clear ];

    [ rtc bindFBO ];

    // add source and obstruction
    [ tempTarget
        attachToRenderTargetConfiguration:rtc
                         colorBufferIndex:0
                                  bindFBO:NO ];

    [ rtc activateDrawBuffers ];
    [ rtc activateViewport ];

    [[[ NP Graphics ] textureBindingState ] setTexture:sourceTexture             texelUnit:0 ];
    [[[ NP Graphics ] textureBindingState ] setTexture:obstructionTexture        texelUnit:1 ];
    [[[ NP Graphics ] textureBindingState ] setTexture:[ heightsTarget texture ] texelUnit:2 ];
    [[[ NPEngineGraphics instance ] textureBindingState ] activate ];

    [ addSourceObstructionT activate ];
    [ fullscreenQuad render ];
    [ tempTarget detach:NO ];

    // compute vertical derivative through convolution
    [ derivativeTarget
        attachToRenderTargetConfiguration:rtc
                         colorBufferIndex:0
                                  bindFBO:NO ];

    [[[ NP Graphics ] textureBindingState ] setTexture:[ tempTarget texture ]  texelUnit:0 ];
    [[[ NP Graphics ] textureBindingState ] setTexture:kernelTexture           texelUnit:1 ];
    [[[ NPEngineGraphics instance ] textureBindingState ] activate ];

    [ kernelRadiusV setValue:kernelRadius ];
    [ convolutionT activate ];
    [ fullscreenQuad render ];
    [ derivativeTarget detach:NO ];
    
    // do propagation
    [ heightsTarget
        attachToRenderTargetConfiguration:rtc
                         colorBufferIndex:0
                                  bindFBO:NO ];

    [[[ NP Graphics ] textureBindingState ] setTexture:[ tempTarget        texture ] texelUnit:0 ];
    [[[ NP Graphics ] textureBindingState ] setTexture:[ prevHeightsTarget texture ] texelUnit:1 ];
    [[[ NP Graphics ] textureBindingState ] setTexture:[ derivativeTarget  texture ] texelUnit:2 ];
    [[[ NPEngineGraphics instance ] textureBindingState ] activate ];

    FVector2 parameters = {.x = accumulatedDeltaTime, .y = alpha};
    [ dtAlphaV setFValue:parameters ];
    [[ effect techniqueWithName:@"propagation" ] activate ];
    [ fullscreenQuad render ];
    [ heightsTarget detach:NO ];

    [ rtc deactivate ];

    // copy tempTarget to prevHeightsTarget
    [[[ NP Graphics ] textureBindingState ] clear ];

    glBindFramebuffer(GL_READ_FRAMEBUFFER, [ rtc glID ]);
    glBindFramebuffer(GL_DRAW_FRAMEBUFFER, [ rtc glID ]);

    glFramebufferTexture2D(GL_READ_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, [[ tempTarget        texture ] glID ], 0);
    glFramebufferTexture2D(GL_DRAW_FRAMEBUFFER, GL_COLOR_ATTACHMENT1, GL_TEXTURE_2D, [[ prevHeightsTarget texture ] glID ], 0);

    glReadBuffer(GL_COLOR_ATTACHMENT0);
    glDrawBuffer(GL_COLOR_ATTACHMENT1);

    glBlitFramebuffer(0, 0, resolution.x, resolution.y, 0, 0, resolution.x, resolution.y, GL_COLOR_BUFFER_BIT, GL_NEAREST);

    glFramebufferTexture2D(GL_READ_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, 0, 0);
    glFramebufferTexture2D(GL_DRAW_FRAMEBUFFER, GL_COLOR_ATTACHMENT1, GL_TEXTURE_2D, 0, 0);

    glBindFramebuffer(GL_READ_FRAMEBUFFER, 0);
    glBindFramebuffer(GL_DRAW_FRAMEBUFFER, 0);

    glReadBuffer(GL_BACK);
    glDrawBuffer(GL_BACK);

    // copy heights to yStream
    glBindFramebuffer(GL_READ_FRAMEBUFFER, [ rtc glID ]);
    glFramebufferTexture2D(GL_READ_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, [[ heightsTarget texture ] glID ], 0);
    glReadBuffer(GL_COLOR_ATTACHMENT0);

    glBindBuffer(GL_PIXEL_PACK_BUFFER, [ yStream glID ]);
    glReadPixels(0, 0, resolution.x, resolution.y, GL_RED, GL_FLOAT, NULL);
    glBindBuffer(GL_PIXEL_PACK_BUFFER, 0);

    glFramebufferTexture2D(GL_READ_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, 0, 0);
    glBindFramebuffer(GL_READ_FRAMEBUFFER, 0);
    glReadBuffer(GL_BACK);

    // reset
    accumulatedDeltaTime = 0.0;

    memset(source, 0, sizeof(float) * resolution.x * resolution.y);
}

- (void) render
{
    [ mesh renderWithPrimitiveType:NpPrimitiveTriangles ];
}

@end

