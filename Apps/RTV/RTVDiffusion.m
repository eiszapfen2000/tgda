#import "NP.h"
#import "RTVCore.h"
#import "RTVDiffusion.h"

@implementation RTVDiffusion

- (id) init
{
    return [ self initWithName:@"Diffusion" ];
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

    diffusionEffect = [[[ NP Graphics ] effectManager ] loadEffectFromPath:@"Diffusion.cgfx" ];
    alpha = [ diffusionEffect parameterWithName:@"alpha" ];
    rBeta = [ diffusionEffect parameterWithName:@"rBeta" ];

    diffusionRenderTargetConfiguration = [[ NPRenderTargetConfiguration alloc ] initWithName:@"DiffusionRT" parent:self ];
//    [ diffusionRenderTargetConfiguration setWidth :v->x ];
//    [ diffusionRenderTargetConfiguration setHeight:v->y ];


    numberOfIterations = 20;

    return self;
}

- (void) dealloc
{
    iv2_free(currentResolution);
    iv2_free(resolutionLastFrame);

    [ diffusionRenderTargetConfiguration clear ];
    [ diffusionRenderTargetConfiguration release ];

    [ super dealloc ];
}

- (Int32) numberOfIterations
{
    return numberOfIterations;
}

- (IVector2) resolution
{
    return *currentResolution;
}

- (void) setNumberOfIterations:(Int32)newNumberOfIterations
{
    numberOfIterations = newNumberOfIterations;
}

- (void) setResolution:(IVector2)newResolution
{
    currentResolution->x = newResolution.x;
    currentResolution->y = newResolution.y;

    [ diffusionRenderTargetConfiguration setWidth :currentResolution->x ];
    [ diffusionRenderTargetConfiguration setHeight:currentResolution->y ];
}

- (void) diffuseQuantityFrom:(id)quantitySource to:(id)quantityTarget
{
    id source = quantitySource;
    id target = quantityTarget;
    id tmp;

    [ diffusionRenderTargetConfiguration bindFBO ];
    [ diffusionRenderTargetConfiguration activateViewport ];
    [ diffusionEffect uploadFloatParameter:alpha andValue:1.0f ];
    [ diffusionEffect uploadFloatParameter:rBeta andValue:1.0f ];

    for ( Int i = 0; i < numberOfIterations; i++ )
    {
        [[ diffusionRenderTargetConfiguration colorTargets ] replaceObjectAtIndex:0 withObject:target ];
        [ target attachToColorBufferIndex:0 ];
        [ diffusionRenderTargetConfiguration activateDrawBuffers ];

        [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:NO stencilBuffer:NO ];

        [[ source texture ] activateAtColorMapIndex:0 ];
        [ diffusionEffect activateTechniqueWithName:@"diffuse" ];

        glBegin(GL_QUADS);
            glVertex4f(-1.0f,  1.0f, 0.0f, 1.0f);
            glVertex4f(-1.0f, -1.0f, 0.0f, 1.0f);
            glVertex4f( 1.0f, -1.0f, 0.0f, 1.0f);
            glVertex4f( 1.0f,  1.0f, 0.0f, 1.0f);
        glEnd();

        [ diffusionEffect deactivate ];

        tmp = source;
        source = target;
        target = tmp;
    }

    [ diffusionRenderTargetConfiguration unbindFBO ];
    [ diffusionRenderTargetConfiguration deactivateDrawBuffers ];
    [ diffusionRenderTargetConfiguration deactivateViewport ];
}

- (void) update:(Float)frameTime
{
}

- (void) render
{
}

@end
