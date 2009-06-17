#import "NP.h"
#import "RTVCore.h"
#import "RTVAdvection.h"
#import "RTVDiffusion.h"
#import "RTVInputForce.h"
#import "RTVDivergence.h"
#import "RTVPressure.h"
#import "RTVArbitraryBoundaries.h"
#import "RTVFluid.h"

@implementation RTVFluid

- (id) init
{
    return [ self initWithName:@"Fluid" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    currentResolution = iv2_alloc_init();
    resolutionLastFrame = iv2_alloc_init();

    projection = fm4_alloc_init();
    identity   = fm4_alloc_init();
    fm4_mssss_orthographic_2d_projection_matrix(projection, 0.0f, 1.0f, 0.0f, 1.0f);

    deltaX = deltaY = 1.0f;
    viscosity = 0.005;

    advection  = [[ RTVAdvection  alloc ] initWithName:@"Advection"  parent:self ];
    diffusion  = [[ RTVDiffusion  alloc ] initWithName:@"Diffusion"  parent:self ];
    inputForce = [[ RTVInputForce alloc ] initWithName:@"InputForce" parent:self ];
    divergence = [[ RTVDivergence alloc ] initWithName:@"Divergence" parent:self ];
    pressure   = [[ RTVPressure   alloc ] initWithName:@"Pressure"   parent:self ];
    arbitraryBoundaries = [[ RTVArbitraryBoundaries alloc ] initWithName:@"ArbitraryBoundaries" parent:self ];

    addVelocityAction = [[[ NP Input ] inputActions ] addInputActionWithName:@"AddVelocity" primaryInputAction:NP_INPUT_MOUSE_BUTTON_LEFT   ];
    addInkAction      = [[[ NP Input ] inputActions ] addInputActionWithName:@"AddInk"      primaryInputAction:NP_INPUT_MOUSE_BUTTON_RIGHT  ];
    addBoundaryAction = [[[ NP Input ] inputActions ] addInputActionWithName:@"AddBoundary" primaryInputAction:NP_INPUT_MOUSE_BUTTON_MIDDLE ];

    fluidRenderTargetConfiguration = [[ NPRenderTargetConfiguration alloc ] initWithName:@"FluidRT" parent:self ];

    return self;
}

- (void) dealloc
{
    iv2_free(currentResolution);
    iv2_free(resolutionLastFrame);

    fm4_free(projection);
    fm4_free(identity);

    DESTROY(advection);
    DESTROY(diffusion);
    DESTROY(inputForce);
    DESTROY(divergence);
    DESTROY(pressure);
    DESTROY(arbitraryBoundaries);

    DESTROY(inkSource);
    DESTROY(inkTarget);
    DESTROY(velocitySource);
    DESTROY(velocityTarget);
    DESTROY(divergenceTarget);
    DESTROY(pressureSource);
    DESTROY(pressureTarget);
    DESTROY(arbitraryBoundariesPaint);
    DESTROY(arbitraryBoundariesVelocity);
    DESTROY(arbitraryBoundariesPressure);

    [ fluidRenderTargetConfiguration clear ];
    DESTROY(fluidRenderTargetConfiguration);

    [ super dealloc ];
}

- (IVector2) resolution
{
    return *currentResolution;
}

- (Int32) width
{
    return currentResolution->x;
}

- (Int32) height
{
    return currentResolution->y;
}

- (id) advection
{
    return advection;
}

- (id) diffusion
{
    return diffusion;
}

- (id) inputForce
{
    return inputForce;
}

- (id) divergence
{
    return divergence;
}

- (id) pressure
{
    return pressure;
}

- (id) velocitySource
{
    return velocitySource;
}

- (id) velocityTarget
{
    return velocityTarget;
}

- (id) velocityBiLerp
{
    return velocityBiLerp;
}

- (id) inkSource
{
    return inkSource;
}

- (id) inkTarget
{
    return inkTarget;
}

- (id) divergenceTarget
{
    return divergenceTarget;
}

- (id) pressureSource
{
    return pressureSource;
}

- (id) pressureTarget
{
    return pressureTarget;
}

- (id) arbitraryBoundariesPaint
{
    return arbitraryBoundariesPaint;
}

- (id) arbitraryBoundariesVelocity
{
    return arbitraryBoundariesVelocity;
}

- (id) arbitraryBoundariesPressure
{
    return arbitraryBoundariesPressure;
}

- (void) setResolution:(IVector2)newResolution
{
    currentResolution->x = newResolution.x;
    currentResolution->y = newResolution.y;

    [ fluidRenderTargetConfiguration setWidth :newResolution.x ];
    [ fluidRenderTargetConfiguration setHeight:newResolution.y ];

    [ advection  setResolution:newResolution ];
    [ inputForce setResolution:newResolution ];
    [ diffusion  setResolution:newResolution ];
    [ divergence setResolution:newResolution ];
    [ pressure   setResolution:newResolution ];
    [ arbitraryBoundaries setResolution:newResolution ];
}

- (BOOL) loadFromPath:(NSString *)path
{
    NSDictionary * sceneConfig = [ NSDictionary dictionaryWithContentsOfFile:path ];

    NSString * sceneName = [ sceneConfig objectForKey:@"Name" ];
    if ( sceneName == nil )
    {
        NPLOG_ERROR(@"%@: Name missing", path);
        return NO;
    }

    IVector2 tmp;
    NSArray * fluidResolutionStrings = [ sceneConfig objectForKey:@"FluidResolution" ];
    if ( fluidResolutionStrings == nil )
    {
        NPLOG_WARNING(@"%@: Size missing, using default", path);

        tmp.x = tmp.y = 128;
    }
    else
    {
        tmp.x = [[ fluidResolutionStrings objectAtIndex:0 ] intValue ];
        tmp.y = [[ fluidResolutionStrings objectAtIndex:1 ] intValue ];
    }

    [ self setResolution:tmp ];

    Int32 diffusionIterations;
    NSString * diffusionIterationsString = [ sceneConfig objectForKey:@"DiffusionIterations" ];
    if ( diffusionIterationsString == nil )
    {
        NPLOG_WARNING(@"%@: Diffusion Iterations missing, using default", path);
        diffusionIterations = 21;
    }
    else
    {
        diffusionIterations = [ diffusionIterationsString intValue ];

        if ( diffusionIterations % 2 == 0 )
        {
            diffusionIterations = diffusionIterations + 1;
        }
    }

    [ diffusion setNumberOfIterations:diffusionIterations ];    

    Int32 pressureIterations;
    NSString * pressureIterationsString = [ sceneConfig objectForKey:@"PressureIterations" ];
    if ( pressureIterationsString == nil )
    {
        NPLOG_WARNING(@"%@: Pressure Iterations missing, using default", path);
        pressureIterations = 21;
    }
    else
    {
        pressureIterations = [ pressureIterationsString intValue ];

        if ( pressureIterations % 2 == 0 )
        {
            pressureIterations = diffusionIterations + 1;
        }
    }

    [ pressure setNumberOfIterations:pressureIterations ];

    NSString * viscosityString = [ sceneConfig objectForKey:@"Viscosity" ];
    if ( viscosityString == nil )
    {
        NPLOG_WARNING(@"%@: Viscosity missing, using default", path);
        viscosity = 0.1f;
    }
    else
    {
        viscosity = [ viscosityString floatValue ];
    }

    NSString * arbitraryBoundariesString = [ sceneConfig objectForKey:@"ArbitraryBoundaries" ];
    if ( arbitraryBoundariesString == nil )
    {
        NPLOG_WARNING(@"%@: ArbitraryBoundaries missing, using default", path);
        useArbitraryBoundaries = NO;
    }
    else
    {
        useArbitraryBoundaries = [ arbitraryBoundariesString boolValue ];
    }

    return YES;
}

- (void) updateVelocityBiLerp
{
    [ fluidRenderTargetConfiguration resetColorTargetsArray ];
    [[ fluidRenderTargetConfiguration colorTargets ] replaceObjectAtIndex:0 withObject:velocitySource ];
    [ fluidRenderTargetConfiguration bindFBO ];
    [ velocitySource attachToColorBufferIndex:0 ];
    [ fluidRenderTargetConfiguration activateDrawBuffers ];
    [ fluidRenderTargetConfiguration activateViewport ];
    [ fluidRenderTargetConfiguration checkFrameBufferCompleteness ];

    [ fluidRenderTargetConfiguration copyColorBuffer:0 toTexture:velocityBiLerp ];

    [ velocitySource detach ];
    [ fluidRenderTargetConfiguration unbindFBO ];
    [ fluidRenderTargetConfiguration deactivateDrawBuffers ];
    [ fluidRenderTargetConfiguration deactivateViewport ];
    [ fluidRenderTargetConfiguration resetColorTargetsArray ];
}

- (void) createVelocityRenderTextures
{
    if ( velocitySource != nil )
    {
        DESTROY(velocitySource);
    }

    if ( velocityTarget != nil )
    {
        DESTROY(velocityTarget);
    }

    if ( velocityBiLerp != nil )
    {
        DESTROY(velocityBiLerp);
    }

    id velocitySourceRenderTexture = [ NPRenderTexture renderTextureWithName:@"VelocityOne"
                                                                        type:NP_GRAPHICS_RENDERTEXTURE_COLOR_TYPE
                                                                       width:currentResolution->x
                                                                      height:currentResolution->y
                                                                  dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_FLOAT
                                                                 pixelFormat:NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA
                                                            textureMinFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST
                                                            textureMagFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST
                                                                textureWrapS:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE
                                                                textureWrapT:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE ];

    id velocityTargetRenderTexture = [ NPRenderTexture renderTextureWithName:@"VelocityTwo"
                                                                        type:NP_GRAPHICS_RENDERTEXTURE_COLOR_TYPE
                                                                       width:currentResolution->x
                                                                      height:currentResolution->y
                                                                  dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_FLOAT
                                                                 pixelFormat:NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA
                                                            textureMinFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST
                                                            textureMagFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST
                                                                textureWrapS:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE
                                                                textureWrapT:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE ];

    velocityBiLerp = [[[ NP Graphics ] textureManager ] createTextureWithName:@"VelocityBilinear"
                                                                        width:currentResolution->x
                                                                       height:currentResolution->y
                                                                   dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_FLOAT
                                                                  pixelFormat:NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA
                                                                   mipMapping:NO ];

    [ velocityBiLerp setTextureMinFilter:NP_GRAPHICS_TEXTURE_FILTER_LINEAR ];
    [ velocityBiLerp setTextureMagFilter:NP_GRAPHICS_TEXTURE_FILTER_LINEAR ];
    [ velocityBiLerp setTextureWrapS:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE ];
    [ velocityBiLerp setTextureWrapT:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE ];
    [ velocityBiLerp uploadToGLWithoutData ];

    velocitySource = [ velocitySourceRenderTexture retain ];
    velocityTarget = [ velocityTargetRenderTexture retain ];
}

- (void) createInkRenderTextures
{
    if ( inkSource != nil )
    {
        DESTROY(inkSource);
    }

    if ( inkTarget != nil )
    {
        DESTROY(inkTarget);
    }

    id inkSourceRenderTexture = [ NPRenderTexture renderTextureWithName:@"InkSource"
                                                                   type:NP_GRAPHICS_RENDERTEXTURE_COLOR_TYPE
                                                                  width:currentResolution->x
                                                                 height:currentResolution->y
                                                             dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_FLOAT
                                                            pixelFormat:NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA
                                                       textureMinFilter:NP_GRAPHICS_TEXTURE_FILTER_LINEAR
                                                       textureMagFilter:NP_GRAPHICS_TEXTURE_FILTER_LINEAR
                                                           textureWrapS:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE
                                                           textureWrapT:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE ];

    id inkTargetRenderTexture = [ NPRenderTexture renderTextureWithName:@"InkTarget"
                                                                   type:NP_GRAPHICS_RENDERTEXTURE_COLOR_TYPE
                                                                  width:currentResolution->x
                                                                 height:currentResolution->y
                                                             dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_FLOAT
                                                            pixelFormat:NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA
                                                       textureMinFilter:NP_GRAPHICS_TEXTURE_FILTER_LINEAR
                                                       textureMagFilter:NP_GRAPHICS_TEXTURE_FILTER_LINEAR
                                                           textureWrapS:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE
                                                           textureWrapT:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE ];

    inkSource = [ inkSourceRenderTexture retain ];
    inkTarget = [ inkTargetRenderTexture retain ];
}

- (void) createDivergenceRenderTexture
{
    if ( divergenceTarget != nil )
    {
        DESTROY(divergenceTarget);
    }

    id divergenceRenderTexture = [ NPRenderTexture renderTextureWithName:@"DivergenceTarget"
                                                                    type:NP_GRAPHICS_RENDERTEXTURE_COLOR_TYPE
                                                                   width:currentResolution->x
                                                                  height:currentResolution->y
                                                              dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_FLOAT
                                                             pixelFormat:NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA
                                                        textureMinFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST
                                                        textureMagFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST
                                                            textureWrapS:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE
                                                            textureWrapT:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE ];

    divergenceTarget = [ divergenceRenderTexture retain ];
}

- (void) createPressureRenderTextures
{
    if ( pressureSource != nil )
    {
        DESTROY(pressureSource);
    }

    if ( pressureTarget != nil )
    {
        DESTROY(pressureTarget);
    }

    id pressureSourceRenderTexture = [ NPRenderTexture renderTextureWithName:@"PressureSource"
                                                                   type:NP_GRAPHICS_RENDERTEXTURE_COLOR_TYPE
                                                                  width:currentResolution->x
                                                                 height:currentResolution->y
                                                             dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_FLOAT
                                                            pixelFormat:NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA
                                                       textureMinFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST
                                                       textureMagFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST
                                                           textureWrapS:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE
                                                           textureWrapT:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE ];

    id pressureTargetRenderTexture = [ NPRenderTexture renderTextureWithName:@"PressureTarget"
                                                                   type:NP_GRAPHICS_RENDERTEXTURE_COLOR_TYPE
                                                                  width:currentResolution->x
                                                                 height:currentResolution->y
                                                             dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_FLOAT
                                                            pixelFormat:NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA
                                                       textureMinFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST
                                                       textureMagFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST
                                                           textureWrapS:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE
                                                           textureWrapT:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE ];

    pressureSource = [ pressureSourceRenderTexture retain ];
    pressureTarget = [ pressureTargetRenderTexture retain ];
}

- (void) createArbitraryBoundariesRenderTextures
{
    if ( arbitraryBoundariesPaint != nil )
    {
        DESTROY(arbitraryBoundariesPaint);
    }

    if ( arbitraryBoundariesVelocity != nil )
    {
        DESTROY(arbitraryBoundariesVelocity);
    }

    if ( arbitraryBoundariesPressure != nil )
    {
        DESTROY(arbitraryBoundariesPressure);
    }

    id arbitraryBoundariesPaintRenderTexture = 
    [ NPRenderTexture renderTextureWithName:@"BoundariesPaint"
                                       type:NP_GRAPHICS_RENDERTEXTURE_COLOR_TYPE
                                      width:currentResolution->x
                                     height:currentResolution->y
                                 dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_FLOAT
                                pixelFormat:NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA
                           textureMinFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST
                           textureMagFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST
                               textureWrapS:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE
                               textureWrapT:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE ];

    id arbitraryBoundariesVelocityRenderTexture =
    [ NPRenderTexture renderTextureWithName:@"BoundariesVelocity"
                                       type:NP_GRAPHICS_RENDERTEXTURE_COLOR_TYPE
                                      width:currentResolution->x
                                     height:currentResolution->y
                                 dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_FLOAT
                                pixelFormat:NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA
                           textureMinFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST
                           textureMagFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST
                               textureWrapS:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE
                               textureWrapT:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE ];

    id arbitraryBoundariesPressureRenderTexture =
    [ NPRenderTexture renderTextureWithName:@"BoundariesPressure"
                                       type:NP_GRAPHICS_RENDERTEXTURE_COLOR_TYPE
                                      width:currentResolution->x
                                     height:currentResolution->y
                                 dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_FLOAT
                                pixelFormat:NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA
                           textureMinFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST
                           textureMagFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST
                               textureWrapS:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE
                               textureWrapT:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE ];

    arbitraryBoundariesPaint    = [ arbitraryBoundariesPaintRenderTexture    retain ];
    arbitraryBoundariesVelocity = [ arbitraryBoundariesVelocityRenderTexture retain ];
    arbitraryBoundariesPressure = [ arbitraryBoundariesPressureRenderTexture retain ];
}

- (void) clearRenderTextures:(NSArray *)renderTextures
{
    [ fluidRenderTargetConfiguration resetColorTargetsArray ];

    NSRange range;
    range.location = 0;
    range.length = [ renderTextures count ];

    [[ fluidRenderTargetConfiguration colorTargets ] replaceObjectsInRange:range withObjectsFromArray:renderTextures range:range ];

    [ fluidRenderTargetConfiguration bindFBO ];

    for ( UInt32 i = 0; i < [ renderTextures count ]; i++ )
    {
        [[ renderTextures objectAtIndex:i ] attachToColorBufferIndex:i ];
    }

    [ fluidRenderTargetConfiguration activateDrawBuffers ];
    [ fluidRenderTargetConfiguration activateViewport ];
    [ fluidRenderTargetConfiguration checkFrameBufferCompleteness ];

    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:NO stencilBuffer:NO ];

    for ( UInt32 i = 0; i < [ renderTextures count ]; i++ )
    {
        [[ renderTextures objectAtIndex:i ] detach ];
    }

    [ fluidRenderTargetConfiguration unbindFBO ];
    [ fluidRenderTargetConfiguration deactivateDrawBuffers ];
    [ fluidRenderTargetConfiguration deactivateViewport ];

    [ fluidRenderTargetConfiguration resetColorTargetsArray ];    
}

- (void) clearVelocityRenderTextures
{
    [ self clearRenderTextures:[NSArray arrayWithObjects:velocitySource, velocityTarget, nil] ];
    [ self updateVelocityBiLerp ];
}

- (void) clearInkRenderTextures
{
    [ self clearRenderTextures:[NSArray arrayWithObjects:inkSource, inkTarget, nil] ];
}

- (void) clearDivergenceRenderTexture
{
    [ self clearRenderTextures:[NSArray arrayWithObjects:divergenceTarget, nil] ];
}

- (void) clearPressureRenderTextures
{
    [ self clearRenderTextures:[NSArray arrayWithObjects:pressureSource, pressureTarget, nil] ];
}

- (void) clearArbitraryBoundariesRenderTextures
{
    [ self clearRenderTextures:[NSArray arrayWithObjects:arbitraryBoundariesPaint, arbitraryBoundariesVelocity, arbitraryBoundariesPressure, nil] ];
}

- (void) updateRenderTextures
{
    [ self createVelocityRenderTextures ];
    [ self createInkRenderTextures ];
    [ self createDivergenceRenderTexture ];
    [ self createPressureRenderTextures ];
    [ self createArbitraryBoundariesRenderTextures ];

    [ self clearVelocityRenderTextures ];
    [ self clearInkRenderTextures ];
    [ self clearDivergenceRenderTexture ];
    [ self clearPressureRenderTextures ];
    [ self clearArbitraryBoundariesRenderTextures ];
}

- (void) update:(Float)frameTime
{
    if ( (currentResolution->x != resolutionLastFrame->x) || (currentResolution->y != resolutionLastFrame->y) )
    {
        [ self updateRenderTextures ];

        resolutionLastFrame->x = currentResolution->x;
        resolutionLastFrame->y = currentResolution->y;
    }

    // Updates rendertarget resolution and other stuff
    [ advection  update:frameTime ];
    [ inputForce update:frameTime ];
    [ diffusion  update:frameTime ];
    [ divergence update:frameTime ];
    [ pressure   update:frameTime ];
    [ arbitraryBoundaries update:frameTime ];

    // Ortho projection
    NPTransformationState * trafo = [[[ NP Core ] transformationStateManager ] currentTransformationState ];
    [ trafo setProjectionMatrix:projection ];

    // Fluid Dynamics start here

    // Copy velocity texture, so that we have a nearest neighbor sampled and a bilinear filtered velocity texture
//    [ self updateVelocityBiLerp ];

    // Advect velocity

    [ advection advectQuantityFrom:velocitySource
                                to:velocityTarget
                     usingVelocity:velocitySource
                         frameTime:frameTime
               arbitraryBoundaries:useArbitraryBoundaries
                 andScaleAndOffset:arbitraryBoundariesVelocity ];


    // Advect ink

    [ advection advectQuantityFrom:inkSource
                                to:inkTarget
                     usingVelocity:velocitySource
                         frameTime:frameTime
               arbitraryBoundaries:NO
                 andScaleAndOffset:nil ];

    // Diffuse velocity

    [ diffusion diffuseQuantityFrom:velocityTarget
                                 to:velocitySource
                        usingDeltaX:deltaX
                             deltaY:deltaY
                          viscosity:viscosity
                       andFrameTime:frameTime ];

    // Diffuse ink

    [ diffusion diffuseQuantityFrom:inkTarget
                                 to:inkSource
                        usingDeltaX:deltaX
                             deltaY:deltaY
                          viscosity:viscosity
                       andFrameTime:frameTime ];

    // Add input force

    if ( [ addVelocityAction active ] == YES )
    {
        [ inputForce addGaussianSplatToQuantity:velocitySource
                                    usingRadius:11.0f
                                          scale:1.0f
                                          color:NULL ];
    }

    if ( [ addInkAction active ] == YES )
    {
        FVector4 brak = { 0.2f, 0.3f, 1.0f, 1.0f };
        [ inputForce addGaussianSplatToQuantity:inkSource
                                    usingRadius:11.0f
                                          scale:1.0f
                                          color:&brak ];
    }

    if ( [ addBoundaryAction active ] == YES && useArbitraryBoundaries == YES )
    {
        [ inputForce addBoundaryBlockToQuantity:arbitraryBoundariesPaint ];

        [ arbitraryBoundaries computeVelocityScaleAndOffsetFromBoundaries:[ arbitraryBoundariesPaint texture ]
                                                                       to:arbitraryBoundariesVelocity ];

        [ arbitraryBoundaries computePressureScaleAndOffsetFromBoundaries:[ arbitraryBoundariesPaint texture ]
                                                                       to:arbitraryBoundariesPressure ];

    }

    // Compute divergence

    [ divergence computeDivergenceFrom:[velocitySource texture]
                                    to:divergenceTarget
                           usingDeltaX:deltaX ];

    // Compute pressure

    /*[ pressure computePressureFrom:pressureSource 
                                to:pressureTarget
                   usingDivergence:divergenceTarget
                            deltaX:deltaX
                            deltaY:deltaY ];*/

    [ pressure computePressureFrom:pressureSource
                                to:pressureTarget
                   usingDivergence:divergenceTarget
                            deltaX:deltaX
                            deltaY:deltaY
               arbitraryBoundaries:useArbitraryBoundaries
                 andScaleAndOffset:arbitraryBoundariesPressure ];

    [ pressure subtractGradientFromVelocity:[velocitySource texture]
                                         to:velocityTarget
                              usingPressure:[ pressureTarget texture ]
                                     deltaX:deltaX ];

    id tmp = velocitySource;
    velocitySource = velocityTarget;
    velocityTarget = tmp;

    /*tmp = inkSource;
    inkSource = inkTarget;
    inkTarget = tmp;*/

    // Reset projection
    [ trafo setProjectionMatrix:identity ];
}

- (void) render
{

}

@end
