#import "NP.h"
#import "RTVCore.h"
#import "RTVAdvection.h"
#import "RTVDiffusion.h"
#import "RTVInputForce.h"
#import "RTVDivergence.h"
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

    advection  = [[ RTVAdvection  alloc ] initWithName:@"Advection"  parent:self ];
    diffusion  = [[ RTVDiffusion  alloc ] initWithName:@"Diffusion"  parent:self ];
    inputForce = [[ RTVInputForce alloc ] initWithName:@"InputForce" parent:self ];
    divergence = [[ RTVDivergence alloc ] initWithName:@"Divergence" parent:self ];

    return self;
}

- (void) dealloc
{
    iv2_free(currentResolution);
    iv2_free(resolutionLastFrame);

    DESTROY(advection);
    DESTROY(diffusion);
    DESTROY(inputForce);
    DESTROY(divergence);

    DESTROY(ink);
    DESTROY(velocitySource);
    DESTROY(velocityTarget);

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

- (id) velocityTarget
{
    return velocityTarget;
}

- (void) setResolution:(IVector2)newResolution
{
    currentResolution->x = newResolution.x;
    currentResolution->y = newResolution.y;

    [ advection  setResolution:newResolution ];
    [ diffusion  setResolution:newResolution ];
    [ divergence setResolution:newResolution ];
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

    if ( ink != nil )
    {
        DESTROY(ink);
    }

    id velocitySourceRenderTexture = [ NPRenderTexture renderTextureWithName:@"VelocitySource"
                                                                        type:NP_GRAPHICS_RENDERTEXTURE_COLOR_TYPE
                                                                       width:currentResolution->x
                                                                      height:currentResolution->y
                                                                  dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_FLOAT
                                                                 pixelFormat:NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA
                                                            textureMinFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST
                                                            textureMagFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST
                                                                textureWrapS:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE
                                                                textureWrapT:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE ];

    id velocityTargetRenderTexture = [ NPRenderTexture renderTextureWithName:@"VelocityTarget"
                                                                        type:NP_GRAPHICS_RENDERTEXTURE_COLOR_TYPE
                                                                       width:currentResolution->x
                                                                      height:currentResolution->y
                                                                  dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_FLOAT
                                                                 pixelFormat:NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA
                                                            textureMinFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST
                                                            textureMagFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST
                                                                textureWrapS:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE
                                                                textureWrapT:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE ];

    id inkRenderTexture = [ NPRenderTexture renderTextureWithName:@"Ink"
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
    ink = [ inkRenderTexture retain ];
}

- (void) update:(Float)frameTime
{
    if ( (currentResolution->x != resolutionLastFrame->x) || (currentResolution->y != resolutionLastFrame->y) )
    {
        [ self updateRenderTextures ];

        resolutionLastFrame->x = currentResolution->x;
        resolutionLastFrame->y = currentResolution->y;
    }

    [ advection update:frameTime ];
    [ diffusion update:frameTime ];

    [ advection advectQuantityFrom:ink to:velocityTarget usingVelocity:velocitySource ];

    //[ advection advectQuantityFrom :componentSource to:componentTarget ];
    //[ diffusion diffuseQuantityFrom:componentTarget to:componentSource ];
}

- (void) render
{

}

@end
