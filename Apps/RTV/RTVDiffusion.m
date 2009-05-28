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

    innerQuadUpperLeft  = fv2_alloc_init();
    innerQuadLowerRight = fv2_alloc_init();
    pixelSize = fv2_alloc_init();

    diffusionEffect = [[[ NP Graphics ] effectManager ] loadEffectFromPath:@"Diffusion.cgfx" ];
    alpha = [ diffusionEffect parameterWithName:@"alpha" ];
    rBeta = [ diffusionEffect parameterWithName:@"rBeta" ];

    diffusionRenderTargetConfiguration = [[ NPRenderTargetConfiguration alloc ] initWithName:@"DiffusionRT" parent:self ];

    numberOfIterations = 21;

    return self;
}

- (void) dealloc
{
    iv2_free(currentResolution);
    iv2_free(resolutionLastFrame);

    fv2_free(innerQuadUpperLeft);
    fv2_free(innerQuadUpperLeft);
    fv2_free(pixelSize);

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
}

- (void) diffuseQuantityFrom:(id)quantitySource to:(id)quantityTarget
{
    id source = quantitySource;
    id target = quantityTarget;
    id tmp;

    [ diffusionRenderTargetConfiguration bindFBO ];
    [ diffusionRenderTargetConfiguration activateViewport ];

    #warning FIXME alpha and beta
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
            glVertex4f(innerQuadUpperLeft->x,  innerQuadUpperLeft->y,  0.0f, 1.0f);
            glVertex4f(innerQuadUpperLeft->x,  innerQuadLowerRight->y, 0.0f, 1.0f);
            glVertex4f(innerQuadLowerRight->x, innerQuadLowerRight->y, 0.0f, 1.0f);
            glVertex4f(innerQuadLowerRight->x, innerQuadUpperLeft->y,  0.0f, 1.0f);
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

- (void) updateInnerQuadCoordinates
{
    pixelSize->x = 1.0f/(Float)(currentResolution->x);
    pixelSize->y = 1.0f/(Float)(currentResolution->y);

    innerQuadUpperLeft->x  = pixelSize->x;
    innerQuadUpperLeft->y  = 1.0f - pixelSize->y;
    innerQuadLowerRight->x = 1.0f - pixelSize->x;
    innerQuadLowerRight->y = pixelSize->y;
}

- (void) update:(Float)frameTime
{
    if ( (currentResolution->x != resolutionLastFrame->x) || (currentResolution->y != resolutionLastFrame->y) )
    {
        [ self updateInnerQuadCoordinates ];

        [ diffusionRenderTargetConfiguration setWidth :currentResolution->x ];
        [ diffusionRenderTargetConfiguration setHeight:currentResolution->y ];

        resolutionLastFrame->x = currentResolution->x;
        resolutionLastFrame->y = currentResolution->y;
    }
}

- (void) render
{
}

@end
