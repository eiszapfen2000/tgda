#import "NP.h"
#import "RTVCore.h"
#import "RTVAdvection.h"
#import "RTVDiffusion.h"
#import "RTVInputForce.h"
#import "RTVDivergence.h"
#import "RTVPressure.h"
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

    advection  = [[ RTVAdvection  alloc ] initWithName:@"Advection"  parent:self ];
    diffusion  = [[ RTVDiffusion  alloc ] initWithName:@"Diffusion"  parent:self ];
    inputForce = [[ RTVInputForce alloc ] initWithName:@"InputForce" parent:self ];
    divergence = [[ RTVDivergence alloc ] initWithName:@"Divergence" parent:self ];
    pressure   = [[ RTVPressure   alloc ] initWithName:@"Pressure"   parent:self ];

    addVelocityAction = [[[ NP Input ] inputActions ] addInputActionWithName:@"AddVelocity" primaryInputAction:NP_INPUT_MOUSE_BUTTON_LEFT  ];
    addInkAction      = [[[ NP Input ] inputActions ] addInputActionWithName:@"AddInk"      primaryInputAction:NP_INPUT_MOUSE_BUTTON_RIGHT ];

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

    DESTROY(inkSource);
    DESTROY(inkTarget);
    DESTROY(velocitySource);
    DESTROY(velocityTarget);

    [ fluidRenderTargetConfiguration clear ];
    DESTROY(fluidRenderTargetConfiguration);

    [ super dealloc ];
}

- (void) clear
{
}

- (void) setup
{
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

    return YES;
}

- (void) activate
{

}

- (void) deactivate
{

}

- (void) updateRenderTextures
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

    if ( inkSource != nil )
    {
        DESTROY(inkSource);
    }

    if ( inkTarget != nil )
    {
        DESTROY(inkTarget);
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

    [ velocityBiLerp setTextureMinFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST ];
    [ velocityBiLerp setTextureMagFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST ];
    [ velocityBiLerp setTextureWrapS:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE ];
    [ velocityBiLerp setTextureWrapT:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE ];
    [ velocityBiLerp uploadToGLWithoutData ];

    id inkSourceRenderTexture = [ NPRenderTexture renderTextureWithName:@"InkSource"
                                                                   type:NP_GRAPHICS_RENDERTEXTURE_COLOR_TYPE
                                                                  width:currentResolution->x
                                                                 height:currentResolution->y
                                                             dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_FLOAT
                                                            pixelFormat:NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA
                                                       textureMinFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST
                                                       textureMagFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST
                                                           textureWrapS:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE
                                                           textureWrapT:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE ];

    id inkTargetRenderTexture = [ NPRenderTexture renderTextureWithName:@"InkTarget"
                                                                   type:NP_GRAPHICS_RENDERTEXTURE_COLOR_TYPE
                                                                  width:currentResolution->x
                                                                 height:currentResolution->y
                                                             dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_FLOAT
                                                            pixelFormat:NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA
                                                       textureMinFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST
                                                       textureMagFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST
                                                           textureWrapS:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE
                                                           textureWrapT:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE ];

    velocitySource = [ velocitySourceRenderTexture retain ];
    velocityTarget = [ velocityTargetRenderTexture retain ];
    inkSource = [ inkSourceRenderTexture retain ];
    inkTarget = [ inkTargetRenderTexture retain ];

    [[ fluidRenderTargetConfiguration colorTargets ] replaceObjectAtIndex:0 withObject:velocitySource ];
    [[ fluidRenderTargetConfiguration colorTargets ] replaceObjectAtIndex:1 withObject:velocityTarget ];
    [[ fluidRenderTargetConfiguration colorTargets ] replaceObjectAtIndex:2 withObject:inkSource ];
    [[ fluidRenderTargetConfiguration colorTargets ] replaceObjectAtIndex:3 withObject:inkTarget ];

    [ fluidRenderTargetConfiguration bindFBO ];

    [ velocitySource attachToColorBufferIndex:0 ];
    [ velocityTarget attachToColorBufferIndex:1 ];
    [ inkSource attachToColorBufferIndex:2 ];
    [ inkTarget attachToColorBufferIndex:3 ];

    [ fluidRenderTargetConfiguration activateDrawBuffers ];
    [ fluidRenderTargetConfiguration activateViewport ];
    [ fluidRenderTargetConfiguration checkFrameBufferCompleteness ];

    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:NO stencilBuffer:NO ];

    [ velocitySource detach ];
    [ velocityTarget detach ];
    [ inkSource detach ];
    [ inkTarget detach ];

    [ fluidRenderTargetConfiguration unbindFBO ];
    [ fluidRenderTargetConfiguration deactivateDrawBuffers ];
    [ fluidRenderTargetConfiguration deactivateViewport ];
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

- (void) update:(Float)frameTime
{
    if ( (currentResolution->x != resolutionLastFrame->x) || (currentResolution->y != resolutionLastFrame->y) )
    {
        [ self updateRenderTextures ];

        resolutionLastFrame->x = currentResolution->x;
        resolutionLastFrame->y = currentResolution->y;
    }

    [ advection  update:frameTime ];
    [ inputForce update:frameTime ];
    [ diffusion  update:frameTime ];

    NPTransformationState * trafo = [[[ NP Core ] transformationStateManager ] currentTransformationState ];
    [ trafo setProjectionMatrix:projection ];


    /*[ advection advectQuantityFrom:inkSource
                                to:inkTarget
                     usingVelocity:velocitySource
                      andFrameTime:frameTime ];*/


    //[ diffusion diffuseQuantityFrom:inkTarget to:inkSource ];

    if ( [ addVelocityAction active ] == YES )
    {
        //[ inputForce addGaussianSplatToQuantity:inkSource ];
    }

    if ( [ addInkAction active ] == YES )
    {
        //NSLog(@"Ink");
    }



    [ trafo setProjectionMatrix:identity ];
}

- (void) render
{

}

@end
