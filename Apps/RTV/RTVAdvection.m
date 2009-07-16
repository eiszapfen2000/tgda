#import "NP.h"
#import "RTVCore.h"
#import "RTVAdvection.h"

@implementation RTVAdvection

- (id) init
{
    return [ self initWithName:@"Advection" ];
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

    advectionEffect = [[[ NP Graphics ] effectManager ] loadEffectFromPath:@"Advection.cgfx" ];
    timestep = [ advectionEffect parameterWithName:@"timestep" ];

    advectionRenderTargetConfiguration = [[ NPRenderTargetConfiguration alloc ] initWithName:@"AdvectionRT" parent:self ];

    return self;
}

- (void) dealloc
{
    iv2_free(currentResolution);
    iv2_free(resolutionLastFrame);

    fv2_free(innerQuadUpperLeft);
    fv2_free(innerQuadUpperLeft);
    fv2_free(pixelSize);

    [ temporaryStorage release ];
    DESTROY(quantityBiLerp);

    [ advectionRenderTargetConfiguration clear ];
    [ advectionRenderTargetConfiguration release ];

    [ super dealloc ];
}

- (IVector2) resolution
{
    return *currentResolution;
}

- (id) quantityBiLerp
{
    return quantityBiLerp;
}

- (id) temporaryStorage
{
    return temporaryStorage;
}

- (void) setResolution:(IVector2)newResolution
{
    currentResolution->x = newResolution.x;
    currentResolution->y = newResolution.y;
}

- (void) advectQuantityFrom:(NPRenderTexture *)quantitySource
                         to:(NPRenderTexture *)quantityTarget
              usingVelocity:(NPRenderTexture *)velocity
                  frameTime:(Float)frameTime
        arbitraryBoundaries:(BOOL)arbitraryBoundaries
          andScaleAndOffset:(NPRenderTexture *)scaleAndOffset
{
    if ( arbitraryBoundaries == YES )
    {
        [ self arbitraryBoundariesAdvectionFrom:quantitySource
                                             to:quantityTarget
                                  usingVelocity:velocity
                                      frameTime:frameTime
                              andScaleAndOffset:scaleAndOffset ];
    }
    else
    {
        [ self normalQuantityAdvectionFrom:quantitySource
                                        to:quantityTarget
                             usingVelocity:velocity
                                 frameTime:frameTime ];
    }
}

- (void) normalQuantityAdvectionFrom:(NPRenderTexture *)quantitySource
                                  to:(NPRenderTexture *)quantityTarget
                       usingVelocity:(NPRenderTexture *)velocity
                           frameTime:(Float)frameTime
{
    [ advectionRenderTargetConfiguration resetColorTargetsArray ];
    [ advectionRenderTargetConfiguration bindFBO ];
    [ advectionRenderTargetConfiguration activateViewport ];

    // copy quantitySource to quantityBiLerp
    [[ advectionRenderTargetConfiguration colorTargets ] replaceObjectAtIndex:0 withObject:quantitySource ];
    [ quantitySource   attachToColorBufferIndex:0 ];
    [ advectionRenderTargetConfiguration activateDrawBuffers ];
    [ advectionRenderTargetConfiguration checkFrameBufferCompleteness ];

    [ advectionRenderTargetConfiguration copyColorBuffer:0 toTexture:[quantityBiLerp texture] ];

    [ quantitySource detach ];

    // Advect inner quad
    [[ advectionRenderTargetConfiguration colorTargets ] replaceObjectAtIndex:0 withObject:quantityTarget   ];
    [[ advectionRenderTargetConfiguration colorTargets ] replaceObjectAtIndex:1 withObject:temporaryStorage ];
    [ quantityTarget   attachToColorBufferIndex:0 ];
    [ temporaryStorage attachToColorBufferIndex:1 ];
    [ advectionRenderTargetConfiguration activateDrawBuffers ];
    [ advectionRenderTargetConfiguration checkFrameBufferCompleteness ];

    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:NO stencilBuffer:NO ];

    [[ velocity       texture ] activateAtColorMapIndex:0 ];
    [[ quantityBiLerp texture ] activateAtColorMapIndex:1 ];

    [ advectionEffect uploadFloatParameter:timestep andValue:frameTime ];
    [ advectionEffect activateTechniqueWithName:@"advect" ];

    glBegin(GL_QUADS);
        glVertex4f(innerQuadUpperLeft->x,  innerQuadUpperLeft->y,  0.0f, 1.0f);
        glVertex4f(innerQuadUpperLeft->x,  innerQuadLowerRight->y, 0.0f, 1.0f);
        glVertex4f(innerQuadLowerRight->x, innerQuadLowerRight->y, 0.0f, 1.0f);
        glVertex4f(innerQuadLowerRight->x, innerQuadUpperLeft->y,  0.0f, 1.0f);
    glEnd();

    [ advectionEffect deactivate ];

    [ temporaryStorage detach ];

    // Draw border lines
    [[ advectionRenderTargetConfiguration colorTargets ] replaceObjectAtIndex:1 withObject:[NSNull null] ];
    [ advectionRenderTargetConfiguration activateDrawBuffers ];
    [ advectionRenderTargetConfiguration checkFrameBufferCompleteness ];

    [[ temporaryStorage texture ] activateAtColorMapIndex:0 ];

    [ advectionEffect activateTechniqueWithName:@"border" ];

    glBegin(GL_LINES);
        glTexCoord2f(pixelSize->x, 0.0f);
        glVertex4f(pixelSize->x*0.5f, 1.0f, 0.0f, 1.0f);
        glTexCoord2f(pixelSize->x, 0.0f);
        glVertex4f(pixelSize->x*0.5f, 0.0f, 0.0f, 1.0f);
    glEnd();

    glBegin(GL_LINES);
        glTexCoord2f(-pixelSize->x, 0.0f);
        glVertex4f(1.0f-pixelSize->x*0.5f, 1.0f, 0.0f, 1.0f);
        glTexCoord2f(-pixelSize->x, 0.0f);
        glVertex4f(1.0f-pixelSize->x*0.5f, 0.0f, 0.0f, 1.0f);
    glEnd();

    glBegin(GL_LINES);
        glTexCoord2f(0.0f, -pixelSize->y);
        glVertex4f(0.0f, 1.0f-pixelSize->y*0.5f, 0.0f, 1.0f);
        glTexCoord2f(0.0f, -pixelSize->y);
        glVertex4f(1.0f, 1.0f-pixelSize->y*0.5f, 0.0f, 1.0f);
    glEnd();

    glBegin(GL_LINES);
        glTexCoord2f(0.0f, pixelSize->y);
        glVertex4f(0.0f, pixelSize->y*0.5f, 0.0f, 1.0f);
        glTexCoord2f(0.0f, pixelSize->y);
        glVertex4f(1.0f, pixelSize->y*0.5f, 0.0f, 1.0f);
    glEnd();

    [ advectionEffect deactivate ];

    [ quantityTarget detach ];    
    [ advectionRenderTargetConfiguration unbindFBO ];
    [ advectionRenderTargetConfiguration deactivateDrawBuffers ];
    [ advectionRenderTargetConfiguration deactivateViewport ];
}

- (void) arbitraryBoundariesAdvectionFrom:(NPRenderTexture *)quantitySource
                                       to:(NPRenderTexture *)quantityTarget
                            usingVelocity:(NPRenderTexture *)velocity
                                frameTime:(Float)frameTime
                        andScaleAndOffset:(NPRenderTexture *)scaleAndOffset
{
    [ advectionRenderTargetConfiguration resetColorTargetsArray ];
    [ advectionRenderTargetConfiguration bindFBO ];
    [ advectionRenderTargetConfiguration activateViewport ];

    [[ advectionRenderTargetConfiguration colorTargets ] replaceObjectAtIndex:0 withObject:quantityBiLerp   ];
    [[ advectionRenderTargetConfiguration colorTargets ] replaceObjectAtIndex:1 withObject:temporaryStorage ];
    [ quantityBiLerp   attachToColorBufferIndex:0 ];
    [ temporaryStorage attachToColorBufferIndex:1 ];
    [ advectionRenderTargetConfiguration activateDrawBuffers ];
    [ advectionRenderTargetConfiguration checkFrameBufferCompleteness ];

    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:NO stencilBuffer:NO ];

    // Arbitrary borders
    [[ velocity       texture ] activateAtColorMapIndex:0 ];
    [[ scaleAndOffset texture ] activateAtColorMapIndex:1 ];

    [ advectionEffect activateTechniqueWithName:@"arbitrary_borders" ];

    /*glBegin(GL_QUADS);
        glVertex4f(innerQuadUpperLeft->x,  innerQuadUpperLeft->y,  0.0f, 1.0f);
        glVertex4f(innerQuadUpperLeft->x,  innerQuadLowerRight->y, 0.0f, 1.0f);
        glVertex4f(innerQuadLowerRight->x, innerQuadLowerRight->y, 0.0f, 1.0f);
        glVertex4f(innerQuadLowerRight->x, innerQuadUpperLeft->y,  0.0f, 1.0f);
    glEnd();*/

    glBegin(GL_QUADS);
        glVertex4f(0.0f, 1.0f, 0.0f, 1.0f);
        glVertex4f(0.0f, 0.0f, 0.0f, 1.0f);
        glVertex4f(1.0f, 0.0f, 0.0f, 1.0f);
        glVertex4f(1.0f, 1.0f, 0.0f, 1.0f);
    glEnd();

    [ advectionEffect deactivate ];

    [ quantityBiLerp   detach ];
    [ temporaryStorage detach ];

    // Advection

    [[ advectionRenderTargetConfiguration colorTargets ] replaceObjectAtIndex:0 withObject:quantityTarget ];
    [[ advectionRenderTargetConfiguration colorTargets ] replaceObjectAtIndex:1 withObject:quantitySource ];
    [ quantityTarget attachToColorBufferIndex:0 ];
    [ quantitySource attachToColorBufferIndex:1 ];
    [ advectionRenderTargetConfiguration activateDrawBuffers ];
    [ advectionRenderTargetConfiguration checkFrameBufferCompleteness ];

    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:NO stencilBuffer:NO ];

    [[ temporaryStorage texture ] activateAtColorMapIndex:0 ];
    [[ quantityBiLerp   texture ] activateAtColorMapIndex:1 ];

    [ advectionEffect uploadFloatParameter:timestep andValue:frameTime ];
    [ advectionEffect activateTechniqueWithName:@"advect" ];

    glBegin(GL_QUADS);
        glVertex4f(innerQuadUpperLeft->x,  innerQuadUpperLeft->y,  0.0f, 1.0f);
        glVertex4f(innerQuadUpperLeft->x,  innerQuadLowerRight->y, 0.0f, 1.0f);
        glVertex4f(innerQuadLowerRight->x, innerQuadLowerRight->y, 0.0f, 1.0f);
        glVertex4f(innerQuadLowerRight->x, innerQuadUpperLeft->y,  0.0f, 1.0f);
    glEnd();

    [ advectionEffect deactivate ];

    [ quantitySource detach ];

    // Draw border lines
    [[ advectionRenderTargetConfiguration colorTargets ] replaceObjectAtIndex:1 withObject:[NSNull null] ];
    [ advectionRenderTargetConfiguration activateDrawBuffers ];
    [ advectionRenderTargetConfiguration checkFrameBufferCompleteness ];

    [[ quantitySource texture ] activateAtColorMapIndex:0 ];

    [ advectionEffect activateTechniqueWithName:@"border" ];

    glBegin(GL_LINES);
        glTexCoord2f(pixelSize->x, 0.0f);
        glVertex4f(pixelSize->x*0.5f, 1.0f, 0.0f, 1.0f);
        glTexCoord2f(pixelSize->x, 0.0f);
        glVertex4f(pixelSize->x*0.5f, 0.0f, 0.0f, 1.0f);
    glEnd();

    glBegin(GL_LINES);
        glTexCoord2f(-pixelSize->x, 0.0f);
        glVertex4f(1.0f-pixelSize->x*0.5f, 1.0f, 0.0f, 1.0f);
        glTexCoord2f(-pixelSize->x, 0.0f);
        glVertex4f(1.0f-pixelSize->x*0.5f, 0.0f, 0.0f, 1.0f);
    glEnd();

    glBegin(GL_LINES);
        glTexCoord2f(0.0f, -pixelSize->y);
        glVertex4f(0.0f, 1.0f-pixelSize->y*0.5f, 0.0f, 1.0f);
        glTexCoord2f(0.0f, -pixelSize->y);
        glVertex4f(1.0f, 1.0f-pixelSize->y*0.5f, 0.0f, 1.0f);
    glEnd();

    glBegin(GL_LINES);
        glTexCoord2f(0.0f, pixelSize->y);
        glVertex4f(0.0f, pixelSize->y*0.5f, 0.0f, 1.0f);
        glTexCoord2f(0.0f, pixelSize->y);
        glVertex4f(1.0f, pixelSize->y*0.5f, 0.0f, 1.0f);
    glEnd();

    [ advectionEffect deactivate ];

    [ quantityTarget detach ];    
    [ advectionRenderTargetConfiguration unbindFBO ];
    [ advectionRenderTargetConfiguration deactivateDrawBuffers ];
    [ advectionRenderTargetConfiguration deactivateViewport ];    

    // borders
    /*[[ quantitySource texture ] activateAtColorMapIndex:0 ];

    [ advectionEffect activateTechniqueWithName:@"border" ];

    glBegin(GL_LINES);
        glTexCoord2f(pixelSize->x, 0.0f);
        glVertex4f(pixelSize->x*0.5f, 1.0f, 0.0f, 1.0f);
        glTexCoord2f(pixelSize->x, 0.0f);
        glVertex4f(pixelSize->x*0.5f, 0.0f, 0.0f, 1.0f);
    glEnd();

    glBegin(GL_LINES);
        glTexCoord2f(-pixelSize->x, 0.0f);
        glVertex4f(1.0f-pixelSize->x*0.5f, 1.0f, 0.0f, 1.0f);
        glTexCoord2f(-pixelSize->x, 0.0f);
        glVertex4f(1.0f-pixelSize->x*0.5f, 0.0f, 0.0f, 1.0f);
    glEnd();

    glBegin(GL_LINES);
        glTexCoord2f(0.0f, -pixelSize->y);
        glVertex4f(0.0f, 1.0f-pixelSize->y*0.5f, 0.0f, 1.0f);
        glTexCoord2f(0.0f, -pixelSize->y);
        glVertex4f(1.0f, 1.0f-pixelSize->y*0.5f, 0.0f, 1.0f);
    glEnd();

    glBegin(GL_LINES);
        glTexCoord2f(0.0f, pixelSize->y);
        glVertex4f(0.0f, pixelSize->y*0.5f, 0.0f, 1.0f);
        glTexCoord2f(0.0f, pixelSize->y);
        glVertex4f(1.0f, pixelSize->y*0.5f, 0.0f, 1.0f);
    glEnd();

    [ advectionEffect deactivate ];

    // Arbitrary borders
    [[ velocity       texture ] activateAtColorMapIndex:0 ];
    [[ scaleAndOffset texture ] activateAtColorMapIndex:1 ];

    [ advectionEffect activateTechniqueWithName:@"arbitrary_borders" ];

    glBegin(GL_QUADS);
        glVertex4f(innerQuadUpperLeft->x,  innerQuadUpperLeft->y,  0.0f, 1.0f);
        glVertex4f(innerQuadUpperLeft->x,  innerQuadLowerRight->y, 0.0f, 1.0f);
        glVertex4f(innerQuadLowerRight->x, innerQuadLowerRight->y, 0.0f, 1.0f);
        glVertex4f(innerQuadLowerRight->x, innerQuadUpperLeft->y,  0.0f, 1.0f);
    glEnd();

    [ advectionEffect deactivate ];

    [ advectionRenderTargetConfiguration copyColorBuffer:0 toTexture:[quantityBiLerp texture] ];

    [ temporaryStorage detach ];

    // Advect
    [[ advectionRenderTargetConfiguration colorTargets ] replaceObjectAtIndex:0 withObject:quantityTarget ];
    [ quantityTarget attachToColorBufferIndex:0 ];
    [ advectionRenderTargetConfiguration activateDrawBuffers ];
    [ advectionRenderTargetConfiguration checkFrameBufferCompleteness ];

    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:NO stencilBuffer:NO ];

    [[ temporaryStorage texture ] activateAtColorMapIndex:0 ];
    [[ quantityBiLerp   texture ] activateAtColorMapIndex:1 ];

    [ advectionEffect uploadFloatParameter:timestep andValue:frameTime ];
    [ advectionEffect activateTechniqueWithName:@"advect" ];

    glBegin(GL_QUADS);
        glVertex4f(innerQuadUpperLeft->x,  innerQuadUpperLeft->y,  0.0f, 1.0f);
        glVertex4f(innerQuadUpperLeft->x,  innerQuadLowerRight->y, 0.0f, 1.0f);
        glVertex4f(innerQuadLowerRight->x, innerQuadLowerRight->y, 0.0f, 1.0f);
        glVertex4f(innerQuadLowerRight->x, innerQuadUpperLeft->y,  0.0f, 1.0f);
    glEnd();

    [ advectionEffect deactivate ];

    [ quantityTarget detach ];    
    [ advectionRenderTargetConfiguration unbindFBO ];
    [ advectionRenderTargetConfiguration deactivateDrawBuffers ];
    [ advectionRenderTargetConfiguration deactivateViewport ];*/
}

- (void) updateQuantityBoundariesFrom:(NPRenderTexture *)quantitySource
                                   to:(NPRenderTexture *)quantityTarget
                  arbitraryBoundaries:(BOOL)arbitraryBoundaries
                    andScaleAndOffset:(NPRenderTexture *)scaleAndOffset
{
    [[ advectionRenderTargetConfiguration colorTargets ] replaceObjectAtIndex:0 withObject:quantityTarget ];
    [ advectionRenderTargetConfiguration bindFBO ];
    [ quantityTarget attachToColorBufferIndex:0 ];
    [ advectionRenderTargetConfiguration activateDrawBuffers ];
    [ advectionRenderTargetConfiguration activateViewport ];
    [ advectionRenderTargetConfiguration checkFrameBufferCompleteness ];

    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:NO stencilBuffer:NO ];

    [[ quantitySource texture ] activateAtColorMapIndex:0 ];

    [ advectionEffect activateTechniqueWithName:@"border" ];

    glBegin(GL_LINES);
        glTexCoord2f(pixelSize->x, 0.0f);
        glVertex4f(pixelSize->x*0.5f, 1.0f, 0.0f, 1.0f);
        glTexCoord2f(pixelSize->x, 0.0f);
        glVertex4f(pixelSize->x*0.5f, 0.0f, 0.0f, 1.0f);
    glEnd();

    glBegin(GL_LINES);
        glTexCoord2f(-pixelSize->x, 0.0f);
        glVertex4f(1.0f-pixelSize->x*0.5f, 1.0f, 0.0f, 1.0f);
        glTexCoord2f(-pixelSize->x, 0.0f);
        glVertex4f(1.0f-pixelSize->x*0.5f, 0.0f, 0.0f, 1.0f);
    glEnd();

    glBegin(GL_LINES);
        glTexCoord2f(0.0f, -pixelSize->y);
        glVertex4f(0.0f, 1.0f-pixelSize->y*0.5f, 0.0f, 1.0f);
        glTexCoord2f(0.0f, -pixelSize->y);
        glVertex4f(1.0f, 1.0f-pixelSize->y*0.5f, 0.0f, 1.0f);
    glEnd();

    glBegin(GL_LINES);
        glTexCoord2f(0.0f, pixelSize->y);
        glVertex4f(0.0f, pixelSize->y*0.5f, 0.0f, 1.0f);
        glTexCoord2f(0.0f, pixelSize->y);
        glVertex4f(1.0f, pixelSize->y*0.5f, 0.0f, 1.0f);
    glEnd();

    [ advectionEffect deactivate ];

    if ( arbitraryBoundaries == YES )
    {
        [[ quantitySource texture ] activateAtColorMapIndex:0 ];
        [[ scaleAndOffset texture ] activateAtColorMapIndex:1 ];

        [ advectionEffect activateTechniqueWithName:@"arbitrary_borders" ];

        glBegin(GL_QUADS);
            glVertex4f(innerQuadUpperLeft->x,  innerQuadUpperLeft->y,  0.0f, 1.0f);
            glVertex4f(innerQuadUpperLeft->x,  innerQuadLowerRight->y, 0.0f, 1.0f);
            glVertex4f(innerQuadLowerRight->x, innerQuadLowerRight->y, 0.0f, 1.0f);
            glVertex4f(innerQuadLowerRight->x, innerQuadUpperLeft->y,  0.0f, 1.0f);
        glEnd();

        [ advectionEffect deactivate ];
    }

    [ quantityTarget detach ];
    [ advectionRenderTargetConfiguration unbindFBO ];
    [ advectionRenderTargetConfiguration deactivateDrawBuffers ];
    [ advectionRenderTargetConfiguration deactivateViewport ];
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

- (void) updateRenderTextures
{
    if ( temporaryStorage != nil )
    {
        DESTROY(temporaryStorage);
    }

    if ( quantityBiLerp != nil )
    {
        DESTROY(quantityBiLerp);
    }

    id tempRenderTexture = [ NPRenderTexture renderTextureWithName:@"ATemp"
                                                              type:NP_GRAPHICS_RENDERTEXTURE_COLOR_TYPE
                                                             width:currentResolution->x
                                                            height:currentResolution->y
                                                        dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_FLOAT
                                                       pixelFormat:NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA
                                                     textureFilter:NP_GRAPHICS_TEXTURE_FILTER_NEAREST
                                                       textureWrap:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE ];

    temporaryStorage = [ tempRenderTexture retain ];



    id quantityBiLerpRenderTexture = [ NPRenderTexture renderTextureWithName:@"QuantityBiLerp"
                                                                        type:NP_GRAPHICS_RENDERTEXTURE_COLOR_TYPE
                                                                       width:currentResolution->x
                                                                      height:currentResolution->y
                                                                  dataFormat:NP_GRAPHICS_TEXTURE_DATAFORMAT_FLOAT
                                                                 pixelFormat:NP_GRAPHICS_TEXTURE_PIXELFORMAT_RGBA
                                                               textureFilter:NP_GRAPHICS_TEXTURE_FILTER_LINEAR
                                                                 textureWrap:NP_GRAPHICS_TEXTURE_WRAPPING_CLAMP_TO_EDGE ];

    quantityBiLerp   = [ quantityBiLerpRenderTexture retain ];

    // Clear render textures
    [ advectionRenderTargetConfiguration resetColorTargetsArray ];
    [[ advectionRenderTargetConfiguration colorTargets ] replaceObjectAtIndex:0 withObject:temporaryStorage ];
    [[ advectionRenderTargetConfiguration colorTargets ] replaceObjectAtIndex:1 withObject:quantityBiLerp   ];

    [ advectionRenderTargetConfiguration bindFBO ];

    [ temporaryStorage attachToColorBufferIndex:0 ];
    [ quantityBiLerp   attachToColorBufferIndex:1 ];

    [ advectionRenderTargetConfiguration activateDrawBuffers ];
    [ advectionRenderTargetConfiguration activateViewport ];
    [ advectionRenderTargetConfiguration checkFrameBufferCompleteness ];

    [[ NP Graphics ] clearFrameBuffer:YES depthBuffer:NO stencilBuffer:NO ];

    [ temporaryStorage detach ];
    [ quantityBiLerp   detach ];

    [ advectionRenderTargetConfiguration unbindFBO ];
    [ advectionRenderTargetConfiguration deactivateDrawBuffers ];
    [ advectionRenderTargetConfiguration deactivateViewport ];

    [ advectionRenderTargetConfiguration resetColorTargetsArray ];
}

- (void) update:(Float)frameTime
{
    if ( (currentResolution->x != resolutionLastFrame->x) || (currentResolution->y != resolutionLastFrame->y) )
    {
        [ self updateRenderTextures ];
        [ self updateInnerQuadCoordinates ];

        [ advectionRenderTargetConfiguration setWidth :currentResolution->x ];
        [ advectionRenderTargetConfiguration setHeight:currentResolution->y ];

        resolutionLastFrame->x = currentResolution->x;
        resolutionLastFrame->y = currentResolution->y;
    }
}

- (void) render
{

}

@end
