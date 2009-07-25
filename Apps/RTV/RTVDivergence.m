#import "NP.h"
#import "RTVCore.h"
#import "RTVDivergence.h"

@implementation RTVDivergence

- (id) init
{
    return [ self initWithName:@"Divergence" ];
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

    divergenceEffect = [[[ NP Graphics ] effectManager ] loadEffectFromPath:@"Divergence.cgfx" ];
    rHalfDX = [ divergenceEffect parameterWithName:@"rHalfDX" ];

    divergenceRenderTargetConfiguration = [[ NPRenderTargetConfiguration alloc ] initWithName:@"DivergenceRT" parent:self ];

    return self;
}

- (void) dealloc
{
    iv2_free(currentResolution);
    iv2_free(resolutionLastFrame);

    fv2_free(innerQuadUpperLeft);
    fv2_free(innerQuadUpperLeft);
    fv2_free(pixelSize);

    [ divergenceRenderTargetConfiguration clear ];
    [ divergenceRenderTargetConfiguration release ];

    [ super dealloc ];
}

- (IVector2) resolution
{
    return *currentResolution;
}

- (void) setResolution:(IVector2 *)newResolution
{
    currentResolution->x = newResolution->x;
    currentResolution->y = newResolution->y;
}

- (void) computeDivergenceFrom:(NPTexture *)source
                            to:(NPRenderTexture *)target
                   usingDeltaX:(Float)deltaX
{
    Float rHalfDXValue = (1.0f / deltaX) * 0.5f;

    [[ divergenceRenderTargetConfiguration colorTargets ] replaceObjectAtIndex:0 withObject:target ];
    [ divergenceRenderTargetConfiguration bindFBO ];
    [ target attachToColorBufferIndex:0 ];
    [ divergenceRenderTargetConfiguration activateDrawBuffers ];
    [ divergenceRenderTargetConfiguration activateViewport ];
    [ divergenceRenderTargetConfiguration checkFrameBufferCompleteness ];

    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:NO stencilBuffer:NO ];

    [ source activateAtColorMapIndex:0 ];

    [ divergenceEffect uploadFloatParameter:rHalfDX andValue:rHalfDXValue  ];
    [ divergenceEffect activateTechniqueWithName:@"divergence" ];

    glBegin(GL_QUADS);
        glVertex4f(innerQuadUpperLeft->x,  innerQuadUpperLeft->y,  0.0f, 1.0f);
        glVertex4f(innerQuadUpperLeft->x,  innerQuadLowerRight->y, 0.0f, 1.0f);
        glVertex4f(innerQuadLowerRight->x, innerQuadLowerRight->y, 0.0f, 1.0f);
        glVertex4f(innerQuadLowerRight->x, innerQuadUpperLeft->y,  0.0f, 1.0f);
    glEnd();

    [ divergenceEffect deactivate ];

    [ target detach ]; 
    [ divergenceRenderTargetConfiguration unbindFBO ];
    [ divergenceRenderTargetConfiguration deactivateDrawBuffers ];
    [ divergenceRenderTargetConfiguration deactivateViewport ];
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

        [ divergenceRenderTargetConfiguration setWidth :currentResolution->x ];
        [ divergenceRenderTargetConfiguration setHeight:currentResolution->y ];

        resolutionLastFrame->x = currentResolution->x;
        resolutionLastFrame->y = currentResolution->y;
    }
}

- (void) render
{

}

@end
