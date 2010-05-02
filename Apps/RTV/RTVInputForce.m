#import "NP.h"
#import "RTVScene.h"
#import "RTVAdvection.h"
#import "RTVInputForce.h"

@implementation RTVInputForce

- (id) init
{
    return [ self initWithName:@"Input Force" ];
}

- (id) initWithName:(NSString *)newName
{
    return [ self initWithName:newName parent:nil ];
}

- (id) initWithName:(NSString *)newName parent:(id <NPPObject>)newParent
{
    self = [ super initWithName:newName parent:newParent ];

    currentResolution   = iv2_alloc_init();
    resolutionLastFrame = iv2_alloc_init();

    innerQuadUpperLeft  = fv2_alloc_init();
    innerQuadLowerRight = fv2_alloc_init();
    pixelSize = fv2_alloc_init();

    inputForceRenderTargetConfiguration = [[ NPRenderTargetConfiguration alloc ] initWithName:@"InputForceRT" parent:self ];

    inputEffect = [[[ NP Graphics ] effectManager ] loadEffectFromPath:@"Input.cgfx" ];
    clickPosition = [ inputEffect parameterWithName:@"clickPosition" ];
    radius = [ inputEffect parameterWithName:@"radius" ];
    color  = [ inputEffect parameterWithName:@"color"  ];

    velocityAndInkStateSet = [[[ NP Graphics ] stateSetManager ] loadStateSetFromPath:@"input.stateset"      ];
    boundariesStateSet     = [[[ NP Graphics ] stateSetManager ] loadStateSetFromPath:@"boundaries.stateset" ];

    return self;
}

- (void) dealloc
{
    iv2_free(currentResolution);
    iv2_free(resolutionLastFrame);

    fv2_free(innerQuadUpperLeft);
    fv2_free(innerQuadUpperLeft);
    fv2_free(pixelSize);

    [ inputForceRenderTargetConfiguration clear ];
    [ inputForceRenderTargetConfiguration release ];

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

- (void) addGaussianSplatToQuantity:(id)quantity
                        usingRadius:(Float)splatRadius
                              scale:(Float)scale
                              color:(FVector4 *)splatColor
{
    IVector2 * controlSize = [[[ NP Graphics ] viewportManager ] currentControlSize ];

    Float mouseX = [[[ NP Input ] mouse ] x ];
    Float mouseY = [[[ NP Input ] mouse ] y ];

    FVector2 normalisedMousePosition;

    // shift to pixel center using + 0.5
    normalisedMousePosition.x = (mouseX + 0.5) / (Float)(controlSize->x);
    normalisedMousePosition.y = (mouseY + 0.5) / (Float)(controlSize->y);

    FVector2 mouseFragmentPosition;
    mouseFragmentPosition.x = normalisedMousePosition.x * currentResolution->x;
    mouseFragmentPosition.y = normalisedMousePosition.y * currentResolution->y;

    [[ inputForceRenderTargetConfiguration colorTargets ] replaceObjectAtIndex:0 withObject:quantity ];
    [ inputForceRenderTargetConfiguration bindFBO ];
    [ quantity attachToColorBufferIndex:0 ];
    [ inputForceRenderTargetConfiguration activateDrawBuffers ];
    [ inputForceRenderTargetConfiguration activateViewport ];
    [ inputForceRenderTargetConfiguration checkFrameBufferCompleteness ];

    [ velocityAndInkStateSet activate ];

    [ inputEffect uploadFloatParameter:radius andValue:splatRadius ];
    [ inputEffect uploadFVector2Parameter:clickPosition andValue:&mouseFragmentPosition ];

    if ( splatColor != NULL )
    {
        [ inputEffect uploadFVector4Parameter:color andValue:splatColor ];
        [ inputEffect activateTechniqueWithName:@"input_ink" ];
    }
    else
    {
        [ inputEffect activateTechniqueWithName:@"input_velocity" ];
    }    

    glBegin(GL_QUADS);
        glVertex4f(innerQuadUpperLeft->x,  innerQuadUpperLeft->y,  0.0f, 1.0f);
        glVertex4f(innerQuadUpperLeft->x,  innerQuadLowerRight->y, 0.0f, 1.0f);
        glVertex4f(innerQuadLowerRight->x, innerQuadLowerRight->y, 0.0f, 1.0f);
        glVertex4f(innerQuadLowerRight->x, innerQuadUpperLeft->y,  0.0f, 1.0f);
    glEnd();

    [ inputEffect deactivate ];

    [ velocityAndInkStateSet deactivate ];

    [ inputForceRenderTargetConfiguration unbindFBO ];
    [ inputForceRenderTargetConfiguration deactivateDrawBuffers ];
    [ inputForceRenderTargetConfiguration deactivateViewport ];
}

- (void) addBoundaryBlockToQuantity:(id)quantity
{
    IVector2 * controlSize = [[[ NP Graphics ] viewportManager ] currentControlSize ];

    Float mouseX = [[[ NP Input ] mouse ] x ];
    Float mouseY = [[[ NP Input ] mouse ] y ];

    FVector2 normalisedMousePosition;

    // shift to pixel center using + 0.5
    normalisedMousePosition.x = (mouseX + 0.5) / (Float)(controlSize->x);
    normalisedMousePosition.y = (mouseY + 0.5) / (Float)(controlSize->y);

    [[ inputForceRenderTargetConfiguration colorTargets ] replaceObjectAtIndex:0 withObject:quantity ];
    [ inputForceRenderTargetConfiguration bindFBO ];
    [ quantity attachToColorBufferIndex:0 ];
    [ inputForceRenderTargetConfiguration activateDrawBuffers ];
    [ inputForceRenderTargetConfiguration activateViewport ];
    [ inputForceRenderTargetConfiguration checkFrameBufferCompleteness ];

    [ boundariesStateSet activate ];

    [ inputEffect activateTechniqueWithName:@"input_boundaries" ];

    glBegin(GL_QUADS);
        glVertex4f(normalisedMousePosition.x - 5.0f * pixelSize->x, normalisedMousePosition.y + 5.0f * pixelSize->y, 0.0f, 1.0f);
        glVertex4f(normalisedMousePosition.x - 5.0f * pixelSize->x, normalisedMousePosition.y - 5.0f * pixelSize->y, 0.0f, 1.0f);
        glVertex4f(normalisedMousePosition.x + 5.0f * pixelSize->x, normalisedMousePosition.y - 5.0f * pixelSize->y, 0.0f, 1.0f);
        glVertex4f(normalisedMousePosition.x + 5.0f * pixelSize->x, normalisedMousePosition.y + 5.0f * pixelSize->y, 0.0f, 1.0f);
    glEnd();

    [ inputEffect deactivate ];

    [ boundariesStateSet deactivate ];

    [ inputForceRenderTargetConfiguration unbindFBO ];
    [ inputForceRenderTargetConfiguration deactivateDrawBuffers ];
    [ inputForceRenderTargetConfiguration deactivateViewport ];
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

        [ inputForceRenderTargetConfiguration setWidth :currentResolution->x ];
        [ inputForceRenderTargetConfiguration setHeight:currentResolution->y ];

        resolutionLastFrame->x = currentResolution->x;
        resolutionLastFrame->y = currentResolution->y;
    }
}

- (void) render
{

}

@end
